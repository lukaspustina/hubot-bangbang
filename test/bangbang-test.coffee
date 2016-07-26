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

        context "use report for server", ->
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


setup_test_env = (env) ->
  process.env.HUBOT_BANGBANG_COMMANDS_FILE = "#{__dirname}/commands-test.js"
  process.env.HUBOT_BOSUN_TIMEOUT = 1000
  process.env.HUBOT_BOSUN_LOG_LEVEL = "error"
  process.env.HUBOT_BANGBANG_ROLE = "bangbang"

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

