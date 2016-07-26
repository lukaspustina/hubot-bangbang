# Description
#   Execute pre-configured commands via hubot !!
#
# Configuration:
#
# Commands:
#
# Notes:
#
# Author:
#   lukas.pustina@gmail.com
#
# Todos:
#   0.1.0
#   * Execute a command
#     * Tests
#       * Command fails
#       * Command does not exist
#       * Timeout fires
#   * Commands
#     * !! help -- show currently available commands
#     * !! reload commands -- reload command definition
#     * !! <...> -- execute a specific command
#   * Output
#     * plain output
#     * pretty print for slack
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
  default_timeout: if process.env.HUBOT_BOSUN_TIMEOUT then parseInt process.env.HUBOT_BOSUN_TIMEOUT else 10000
  log_level: process.env.HUBOT_BOSUN_LOG_LEVEL or "info"
  role: process.env.HUBOT_BANGBANG_ROLE or ""
  slack: process.env.HUBOT_BOSUN_SLACK is "yes"

commands = utils.load_commands_from_file config.commands_file

logger = new Log config.log_level
logger.notice "#{module_name}: Started."

module.exports = (robot) ->

  robot.respond /!! (.*)/i, (res) ->
    unless is_authorized robot, res.envelope.user
      warn_unauthorized res
    else
      user_name = res.envelope.user.name
      command_req = res.match[1]
      logger.info "#{module_name}: '#{command_req}' requested by #{user_name}."

      command = null
      for c in commands
        if match = ///#{c.rexex}///i.exec command_req
          command = c
          command.matches = match[1..]
          command.time = utils.now()
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
            res.reply stdout if stdout.length > 0
            res.reply stderr if stderr.length > 0
          else
            color = if error then 'danger' else 'good'

            # TODO: output_type

            attachments = []
            attachments.push {
              color: color
              title: "stdout"
              text: stdout
              mrkdwn_in: ["text"]
            } if stdout
            attachments.push {
              color: color
              title: "stderr"
              text: stderr
              mrkdwn_in: ["text"]
            } if stderr

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

