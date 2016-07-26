Helper = require('hubot-test-helper')
chai = require 'chai'
Promise = require('bluebird')
co = require('co')

expect = chai.expect

process.env.EXPRESS_PORT = 18080
api_call_delay = 20



describe 'bangbang', ->
  beforeEach ->
    @room = setup_test_env {}

  afterEach ->
    tear_down_test_env @room

  context "authorized", ->

    context "unrecognized", ->

      context "!! anything", ->
        beforeEach ->
          co =>
            yield @room.user.say 'alice', '@hubot !! anything'
            yield new Promise.delay api_call_delay

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
            yield new Promise.delay api_call_delay

        it 'run', ->
          expect(@room.messages).to.eql [
            ['alice', '@hubot !! use report for server']
            ['hubot', "@alice Alright, trying to retrieve an USE report from the specified host with parameters 'server'."]
          ]

  context "unauthorized", ->

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
  process.env.HUBOT_BOSUN_LOG_LEVEL = "debug"
  process.env.HUBOT_BANGBANG_ROLE = "bangbang"

  helper = new Helper('../src/bangbang.coffee')
  room = helper.createRoom()
  room.robot.auth = new MockAuth

  room

tear_down_test_env = (room) ->
  room.destroy()
  # Force reload of module under test
  delete require.cache[require.resolve('../src/bangbang')]


class MockAuth
  hasRole: (user, role) ->
    if user.name is 'alice' and role is 'bangbang' then true else false

