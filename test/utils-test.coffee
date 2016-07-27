chai = require 'chai'
expect = chai.expect

utils = require '../src/utils'

describe 'utils', ->

  context 'load commands from file', ->

    it 'success', ->
      commands = utils.load_commands_from_file "#{__dirname}/commands-test.js"
      expect(commands).to.eql [
        {
          name: "use report",
          description: "retrieve an USE report from the specified host",
          regex: "use report for (.+)",
          exec: 'echo ssh $1 usereport.py',
          timeout: 60,
          output_type: "markdown",
          role: "task_use_report",
        }
      ]

    it 'file not found', ->
      commands = utils.load_commands_from_file "does_not_exists.js"
      expect(commands).to.eql new Error "Could not read command file 'does_not_exists.js'."

    it 'invalid JSON', ->
      commands = utils.load_commands_from_file "invalid-json-test.js"
      expect(commands).to.eql new Error "Could not parse command file 'invalid-json-test.js'."


  context 'bind command parameters', ->

    it 'success', ->
      command = { exec: "ssh $1 ls $2", matches: ["server", "/home"] }
      command_line = utils.bind_command_parameters command
      expect(command_line).to.eql "ssh server ls /home"


  context 'tickets', ->

    it 'create ticket', ->
      command = { line: "ssh server ls /home", time: 1469527900631 }
      ticket = utils.create_ticket command
      expect(ticket).to.eql "b517af8e0991db36ad438d9001eb6c860eb935f1"

    it 'shorten ticket', ->
      command = { line: "ssh server ls /home", time: 1469527900631 }
      ticket = utils.create_ticket command
      short_ticket = utils.shorten_ticket ticket
      expect(short_ticket).to.eql "b517af8"

