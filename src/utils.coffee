child_process = require 'child_process'
crypto = require 'crypto'

module.exports =

  load_commands_from_file: (file) ->
    fs = require 'fs'
    content = try
       fs.readFileSync(file, 'utf8')
    catch error
      null
    return new Error "Could not read command file '#{file}'." unless content
    commands = try
       JSON.parse content
    catch error
      null
    return new Error "Could not parse command file '#{file}'." unless commands

    commands


  # TODO: Asynx
    #var fs = require('fs');
    #var obj;
    #fs.readFile('file', 'utf8', function (err, data) {
      #if (err) throw err;
      #obj = JSON.parse(data);
    #});


  bind_command_parameters: (command) ->
    command_line = command.exec
    matches = command.matches
    for i in [0..matches.length-1]
      command_line = command_line.replace "$#{i+1}", matches[i]
    command_line

  exec_command: (command, handler ) ->
    child_process.exec command.line, {timeout: command.timeout}, handler
    this.create_ticket command


  now: () ->
    new Date().valueOf()

  create_ticket:  (command) ->
    text = command.line + command.time
    ticket = crypto.createHash('sha1').update(text).digest('hex')
    ticket

  shorten_ticket: (ticket) ->
    ticket[0..6]

