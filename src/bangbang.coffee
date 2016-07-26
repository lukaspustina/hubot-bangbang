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

request = require 'request'
Log = require 'log'

module_name = "hubot-bangbang"

config =
  role: process.env.HUBOT_BANGBANG_ROLE or ""

logger = new Log config.log_level
logger.notice "#{module_name}: Started."

module.exports = (robot) ->

  robot.respond /!! (.*)/i, (res) ->
    if is_authorized robot, res
      user_name = res.envelope.user.name
      logger.info "#{module_name}: by #{user_name}."


  robot.error (err, res) ->
    robot.logger.error "#{module_name}: DOES NOT COMPUTE"

    if res?
      res.reply "DOES NOT COMPUTE: #{err}"

is_authorized = (robot, res) ->
  user = res.envelope.user
  unless robot.auth.hasRole(user, config.role)
    warn_unauthorized res
    false
  else
    true

warn_unauthorized = (res) ->
  user = res.envelope.user.name
  message = res.message.text
  logger.warning "#{module_name}: #{user} tried to run '#{message}' but was not authorized."
  res.reply "Sorry, you're not allowed to do that. You need the '#{config.role}' role."

format_date_str = (date_str) ->
  if config.relative_time
    moment(date_str).fromNow()
  else
    date_str.replace(/T/, ' ').replace(/\..+/, ' UTC')
