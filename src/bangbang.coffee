# Description
#   Execute pre-configured commands via hubot !!
#
# Configuration:
#
# Commands:
#   show bangbang commands -- show currently available commands
#   reload bangbang commands -- reload command definition
#
# Notes:
#
# Author:
#   lukas.pustina@gmail.com
#
# Todos:
#   0.1.0
#   * Add extra role checking for command.role
#   * Execute a command
#     * Tests
#       * Command fails
#       * Command does not exist
#       * Timeout fires
#       * Slack Output
#         * markdown
#         * plain
#         * ignore
#         * pretty
#   * Documentation
#     * commands JSON format
#     * Output Types
#   0.2.0
#   * Events
#     * Receive
#       * reload commands
#       * execute command
#     * Send
#       * reload failed|success
#       * execute failed|success


Log = require 'log'
utils = require './utils'

module_name = "hubot-bangbang"

config =
  commands_file: process.env.HUBOT_BANGBANG_COMMANDS_FILE
  default_timeout: if process.env.HUBOT_BANGBANG_TIMEOUT then parseInt process.env.HUBOT_BANGBANG_TIMEOUT else 10000
  log_level: process.env.HUBOT_BANGBANG_LOG_LEVEL or "info"
  role: process.env.HUBOT_BANGBANG_ROLE or ""
  slack: process.env.HUBOT_BANGBANG_SLACK is "yes"

logger = new Log config.log_level
logger.notice "#{module_name}: Started."

load_commands = () ->
  result = utils.load_commands_from_file config.commands_file
  if result instanceof Error
    logger.error "#{module_name}: Failed to load commands, because #{result}"
    {}
  else
    logger.info "#{module_name}: Loaded #{result.length} command#{if result.length > 1 then 's' else ''}."
    result

commands = load_commands()

module.exports = (robot) ->

  robot.respond /show bangbang commands/i, (res) ->
    unless is_authorized robot, res.envelope.user
      warn_unauthorized res
    else
      logger.info "#{module_name}: show bangbang commands requested by #{res.envelope.user.name}."
      msg = if commands.length > 0
        ("!! #{c.regex} - #{c.description}" for c in commands).join('\n')
      else
        "Uh oh, I'm sorry. There no commands availabe right now. Try to reload the commands file."
      res.reply msg


  robot.respond /reload bangbang commands/i, (res) ->
    unless is_authorized robot, res.envelope.user
      warn_unauthorized res
    else
      logger.info "#{module_name}: reload bangbang commands requested by #{res.envelope.user.name}."
      commands = load_commands()
      res.reply "Reloaded. Now I recognize #{commands.length} command#{if commands.length > 1 then 's' else ''}."


  robot.respond /!! (.*)/i, (res) ->
    unless is_authorized robot, res.envelope.user
      warn_unauthorized res
    else
      user_name = res.envelope.user.name
      command_req = res.match[1]
      logger.info "#{module_name}: '#{command_req}' requested by #{user_name}."

      command = null
      for c in commands
        if match = ///#{c.regex}///i.exec command_req
          command = c
          command.matches = match[1..]
          command.time = utils.now()
          command.timeout = config.default_timeout unless command.timeout
          break

      unless command? and command.matches
        logger.info "#{module_name}: Did not recognize any command in '#{command_req}'."
        res.reply "Oh oh! Did not recognize any command in '#{command_req}'."
      else
        logger.info "#{module_name}: Recognized command '#{command.name}' in '#{command_req}'."
        res.reply "Alright, trying to #{c.description} with parameters '#{command.matches}'."

        command.line = utils.bind_command_parameters command
        logger.debug "#{module_name}: Going to execute '#{command.line}'."
        command.ticket = utils.exec_command command, (error, stdout, stderr) ->
          result_msg = if error
            "command with ticket '#{utils.shorten_ticket command.ticket}' finished with error code #{error.code}, because of #{error.signal}."
          else
            "command with ticket '#{utils.shorten_ticket command.ticket}' finished successfully."
          logger.info "#{module_name}: #{result_msg}"

          unless config.slack
            res.reply "Your " + result_msg
            res.reply "Command output for '#{command.line}':"
            res.reply stdout if stdout
            res.reply stderr if stderr
          else
            color = if error then 'danger' else 'good'
            [has_mrkdwn, pretty_out, pretty_err] = switch command.output_type
              when 'markdown' then [
                ["text"]
                stdout or null
                stderr or null
              ]
              when 'pre' then [
                ["text"]
                if stdout? then "```\n#{stdout}\n```" else null
                if stderr? then "```\n#{stderr}\n```" else null
              ]
              else [ # Also applies for 'plain'
                []
                stdout or null
                stderr or null
              ]

            attachments = []
            attachments.push {
              color: color
              title: "stdout"
              text: pretty_out
              mrkdwn_in: has_mrkdwn
            } if pretty_out? and command.out_type != 'ignore'
            attachments.push {
              color: color
              title: "stderr"
              text: pretty_err
              mrkdwn_in: has_mrkdwn
            } if pretty_err? and command.out_type != 'ignore'

            robot.adapter.customMessage {
              channel: res.message.room
              text: "Your " + result_msg
              attachments: attachments
            }

        logger.info "#{module_name}: Ticket for '#{command.line}' is '#{command.ticket}'."
        res.reply "Your ticket is '#{utils.shorten_ticket command.ticket}'."


  robot.error (err, res) ->
    robot.logger.error "#{module_name}: DOES NOT COMPUTE"

    if res?
      res.reply "DOES NOT COMPUTE: #{err}"


is_authorized = (robot, user) ->
  logger.debug "Checking authorization for user '#{user.name}' and role '#{config.role}': role is #{config.role is ""}, auth is #{robot.auth.hasRole(user, config.role)}, combined is #{config.role is "" or robot.auth.hasRole(user, config.role)}."
  config.role is "" or robot.auth.hasRole(user, config.role)

warn_unauthorized = (res) ->
  user = res.envelope.user.name
  message = res.message.text
  logger.warning "hubot-#{module_name}: #{user} tried to run '#{message}' but was not authorized."
  res.reply "Sorry, you're not allowed to do that. You need the '#{config.role}' role."

