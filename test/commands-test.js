[
  {
    "name": "use report",
    "description": "retrieve an USE report from the specified host",
    "rexex": "use report for (.+)",
    "exec": "ssh \\1 usereport.py",
    "timeout": 60,
    "output_type": "markdown",
    "role": "task_use_report"
  }
]

