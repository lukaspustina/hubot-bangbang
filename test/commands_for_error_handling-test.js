[
  {
    "name": "exit",
    "description": "exits with specified code",
    "regex": "exit ([0-9]+)",
    "exec": "exit $1",
    "timeout": 60,
    "output_type": "pre"
  },
  {
    "name": "command does not exists",
    "description": "tries to run a command that does not exists",
    "regex": "does not exist for (.+)",
    "exec": "no_such_command $1",
    "timeout": 60,
    "output_type": "ignore"
  },
  {
    "name": "time out",
    "description": "tries to time out",
    "regex": "time out",
    "exec": "sleep 60",
    "timeout": 1,
    "output_type": "pre"
  }
]

