[
  {
    "name": "date",
    "description": "retrieve local date from the specified host",
    "regex": "date for (.+)",
    "exec": "echo ssh $1 date",
    "timeout": 60,
    "output_type": "plain"
  },
  {
    "name": "use report",
    "description": "retrieve an USE report from the specified host",
    "regex": "use report for (.+)",
    "exec": "echo ssh $1 usereport.py",
    "timeout": 60,
    "output_type": "markdown",
    "role": "bangbang.use_report"
  }
]

