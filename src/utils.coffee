exec = (require 'child_process').exec

module.exports =

  load_commands_from_file: (file) ->
    fs = require 'fs'
    JSON.parse fs.readFileSync(file, 'utf8')

  # TODO: Asynx
    #var fs = require('fs');
    #var obj;
    #fs.readFile('file', 'utf8', function (err, data) {
      #if (err) throw err;
      #obj = JSON.parse(data);
    #});


  bind_command_parameters: (command_prototype, matches) ->
    command = command_prototype
    for i in [1..matches.length-1]
      command = command.replace "$#{i}", matches[i]
    command

  exec_command: (command, timeout, handler ) ->
    exec 'cat *.js bad_file | wc -l', {timeout: timeout}, handler

