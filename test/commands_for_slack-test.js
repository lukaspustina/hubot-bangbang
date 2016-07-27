[
  {
    "name": "mardown",
    "description": "echo markdown",
    "regex": "markdown",
    "exec": "echo '# Title\n\n## Subtitle\n\n This is markdown'",
    "timeout": 60,
    "output_type": "markdown"
  },
  {
    "name": "pre",
    "description": "echo pre",
    "regex": "pre",
    "exec": "echo output",
    "timeout": 60,
    "output_type": "pre"
  },
  {
    "name": "plain",
    "description": "echo plain",
    "regex": "plain$",
    "exec": "echo output",
    "timeout": 60,
    "output_type": "plain"
  },
  {
    "name": "ignore",
    "description": "echo ignore",
    "regex": "ignore",
    "exec": "echo output",
    "timeout": 60,
    "output_type": "ignore"
  },
  {
    "name": "plain_out_err",
    "description": "echo plain to stdout and stderr",
    "regex": "plain_out_err",
    "exec": "echo stdout; echo stderr >&2",
    "timeout": 60,
    "output_type": "plain"
  },
  {
    "name": "fail_out_err",
    "description": "echo plain to stdout and stderr and exit 2",
    "regex": "fail_out_err",
    "exec": "echo stdout; echo stderr >&2; exit 2",
    "timeout": 60,
    "output_type": "plain"
  },
  {
    "name": "fail_err",
    "description": "echo plain to stderr and exit 2",
    "regex": "fail_err",
    "exec": "echo stderr >&2; exit 2",
    "timeout": 60,
    "output_type": "plain"
  }
]

