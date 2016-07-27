Helper = require('hubot-test-helper')
chai = require 'chai'
Promise = require('bluebird')
co = require('co')

utils = require('../src/utils')

expect = chai.expect

process.env.EXPRESS_PORT = 18080
command_execution_delay = 20



describe 'bangbang', ->
  beforeEach ->
    @room = setup_test_env {}

  afterEach ->
    tear_down_test_env @room

  context "authorized", ->

    context "show help", ->
      it 'help', ->
        @room.user.say('alice', '@hubot show bangbang commands').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot show bangbang commands']
            ['hubot', "@alice !! use report for (.+) - retrieve an USE report from the specified host"]
          ]

    context "reload commands", ->
      it 'reload', ->
        @room.user.say('alice', '@hubot reload bangbang commands').then =>
          expect(@room.messages).to.eql [
            ['alice', '@hubot reload bangbang commands']
            ['hubot', "@alice Reloaded. Now I recognize 1 command."]
          ]

    context "run command", ->

      context "unrecognized", ->

        context "!! anything", ->
          beforeEach ->
            co =>
              yield @room.user.say 'alice', '@hubot !! anything'
              yield new Promise.delay command_execution_delay

          it 'run', ->
            expect(@room.messages).to.eql [
              ['alice', '@hubot !! anything']
              ['hubot', "@alice Oh oh! Did not recognize any command in 'anything'."]
            ]

      context "recognized", ->

        context "successful", ->
          beforeEach ->
            co =>
              yield @room.user.say 'alice', '@hubot !! use report for server'
              yield new Promise.delay command_execution_delay

          it 'run', ->
            expect(@room.messages).to.eql [
              ['alice', '@hubot !! use report for server']
              ['hubot', "@alice Alright, trying to retrieve an USE report from the specified host with parameters 'server'."]
              ['hubot', "@alice Your ticket is 'd42a892'."]
              ['hubot', "@alice Your command with ticket 'd42a892' finished successfully."]
              ['hubot', "@alice Command output for 'echo ssh server usereport.py':"]
              ['hubot', "@alice ssh server usereport.py\n"]
            ]

  context "unauthorized", ->

    context "run command", ->

      context "Fail if unauthorized", ->

        it '!! anything', ->
          @room.user.say('bob', '@hubot !! anything').then =>
            expect(@room.messages).to.eql [
              ['bob', '@hubot !! anything']
              ['hubot', "@bob Sorry, you're not allowed to do that. You need the 'bangbang' role."]
            ]


describe 'bangbang error handling', ->
  beforeEach ->
    @room = setup_test_env {
      hubot_bangbang_commands_file: "#{__dirname}/commands_for_error_handling-test.js"
    }

  afterEach ->
    tear_down_test_env @room

  context "authorized", ->

    context "run command", ->

        context "failed, because command failed", ->
          beforeEach ->
            co =>
              yield @room.user.say 'alice', '@hubot !! exit 2'
              yield new Promise.delay command_execution_delay

          it 'run', ->
            expect(@room.messages).to.eql [
              ['alice', '@hubot !! exit 2']
              ['hubot', "@alice Alright, trying to exits with specified code with parameters '2'."]
              ['hubot', "@alice Your ticket is '00e264e'."]
              ['hubot', "@alice Your command with ticket '00e264e' finished with error code 2, because of null."]
              ['hubot', "@alice Command output for 'exit 2':"]
            ]

        context "failed, because command does not exist", ->
          beforeEach ->
            co =>
              yield @room.user.say 'alice', '@hubot !! does not exist for does not matter'
              yield new Promise.delay command_execution_delay

          it 'run', ->
            expect(@room.messages).to.eql [
              ['alice', '@hubot !! does not exist for does not matter']
              ['hubot', "@alice Alright, trying to tries to run a command that does not exists with parameters 'does not matter'."]
              ['hubot', "@alice Your ticket is 'f5d8d6f'."]
              ['hubot', "@alice Your command with ticket 'f5d8d6f' finished with error code 127, because of null."]
              ['hubot', "@alice Command output for 'no_such_command does not matter':"]
              ['hubot', "@alice /bin/sh: no_such_command: command not found\n"]
            ]

        context "failed, because command timedout", ->
          beforeEach ->
            co =>
              yield @room.user.say 'alice', '@hubot !! time out'
              yield new Promise.delay command_execution_delay

          it 'run', ->
            expect(@room.messages).to.eql [
              ['alice', '@hubot !! time out']
              ['hubot', "@alice Alright, trying to tries to time out with parameters ''."]
              ['hubot', "@alice Your ticket is '9b528ca'."]
              ['hubot', "@alice Your command with ticket '9b528ca' finished with error code null, because of SIGTERM."]
              ['hubot', "@alice Command output for 'sleep 60':"]
            ]



describe 'bangbang with Slack', ->
  beforeEach ->
    @room = setup_test_env {
      hubot_bangbang_slack: "yes"
    }

  afterEach ->
    tear_down_test_env @room

  context "authorized", ->

    context "run command", ->

      context "recognized", ->

        context "successful with stdout only formated with markdown", ->
          it "run"

        context "successful with stdout only formated with pre", ->
          it "run"

        context "successful with stdout only formated with plain", ->
          it "run"

        context "successful with stdout only formated with ignore", ->
          it "run"

        context "successful with stdout and stderr", ->
          it "run"

        context "failed with stderr only", ->
          it "run"

        context "failed with stdout and stderr", ->
          it "run"



setup_test_env = (env) ->
  process.env.HUBOT_BANGBANG_COMMANDS_FILE = env.hubot_bangbang_commands_file or "#{__dirname}/commands-test.js"
  process.env.HUBOT_BANGBANG_LOG_LEVEL = env.hubot_bangbang_debug_level or "error"
  process.env.HUBOT_BANGBANG_ROLE = env.hubot_bangbang_role or "bangbang"
  process.env.HUBOT_BANGBANG_SLACK = env.hubot_bangbang_slack or "no"
  process.env.HUBOT_BANGBANG_TIMEOUT = env.hubot_bangbang_slack_timeout or 1000

  unpatched_utils_now = utils.now
  utils.now = () -> 1469527900631

  helper = new Helper('../src/bangbang.coffee')
  room = helper.createRoom()
  room.robot.auth = new MockAuth
  room.unpatched_utils_now = unpatched_utils_now

  room

tear_down_test_env = (room) ->
  utils.now = room.unpatched_utils_now

  room.destroy()
  # Force reload of module under test
  delete require.cache[require.resolve('../src/bangbang')]


class MockAuth
  hasRole: (user, role) ->
    if user.name is 'alice' and role is 'bangbang' then true else false

