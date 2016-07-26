chai = require 'chai'
expect = chai.expect

utils = require '../src/utils'

describe 'utils', ->

  it 'load commands from file', ->
    commands = utils.load_commands_from_file "#{__dirname}/commands-test.js"
    expect(commands).to.eql [
      {
        name: "use report",
        description: "retrieve an USE report from the specified host",
        rexex: "use report for (.+)",
        exec: 'echo ssh $1 usereport.py',
        timeout: 60,
        output_type: "markdown",
        role: "task_use_report",
      }
    ]

  context 'bind command parameters', ->

    it 'success', ->
      command = utils.bind_command_parameters "ssh $1 ls $2", ["full match", "server", "/home"]
      expect(command).to.eql "ssh server ls /home"

