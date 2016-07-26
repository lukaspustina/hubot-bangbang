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

commands = utils.load_commands_from_file config.commands_file

logger = new Log config.log_level
logger.notice "#{module_name}: Started."

module.exports = (robot) ->

  robot.respond /!! (.*)/i, (res) ->
    unless is_authorized robot, res.envelope.user
      warn_unauthorized res
    else
      user_name = res.envelope.user.name
      command_str = res.match[1]
      logger.info "#{module_name}: '#{command_str}' requested by #{user_name}."

      match = null
      command = null
      for c in commands
        if match = ///#{c.rexex}///i.exec command_str
          command = c
          break

      unless match
        logger.info "#{module_name}: Did not recognize any command in '#{command_str}'."
        res.reply "Oh oh! Did not recognize any command in '#{command_str}'."
      else
        logger.info "#{module_name}: Recognized command '#{c.name}' in '#{command_str}'."
        res.reply "Alright, trying to #{c.description} with parameters '#{match[1..]}'."


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

