
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

