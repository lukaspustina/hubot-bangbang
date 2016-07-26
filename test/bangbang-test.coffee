Helper = require('hubot-test-helper')
chai = require 'chai'

expect = chai.expect

process.env.EXPRESS_PORT = 18080
api_call_delay = 20
customMessages = []

describe 'bangbang', ->
  beforeEach ->
    @room = setup_test_env {}

  afterEach ->
    tear_down_test_env @room

setup_test_env = (env) ->
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

