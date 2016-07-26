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
        exec: 'ssh \\1 usereport.py',
        timeout: 60,
        output_type: "markdown",
        role: "task_use_report",
      }
    ]


