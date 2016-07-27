[
  {
    "name": "use report",
    "description": "retrieve an USE report from the specified host",
    "regex": "use report for (.+)",
    "exec": "echo ssh $1 usereport.py",
    "timeout": 60,
    "output_type": "markdown",
    "role": "task_use_report"
  },
  {
    "name": "exit",
    "description": "exits with specified code",
    "regex": "exit ([0-9]+)",
    "exec": "exit $1",
    "timeout": 60,
    "output_type": "pre",
  },
  {
    "name": "command does not exists",
    "description": "tries to run a command that does not exists",
    "regex": "does not exist for (.+)",
    "exec": "no_such_command $1",
    "timeout": 60,
    "output_type": "pre"
  }
]

