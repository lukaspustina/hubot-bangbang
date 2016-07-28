# hubot-bangbang

[![Build Status](https://travis-ci.org/lukaspustina/hubot-bangbang.svg?branch=master)](https://travis-ci.org/lukaspustina/hubot-bangbang)

[![NPM](https://nodei.co/npm/hubot-bangbang.png)](https://nodei.co/npm/hubot-bangbang/)

Execute changeable pre-defined shell commands via hubot in a secure way !!

See [`src/bangbang.coffee`](src/bangbang.coffee) for full documentation.

## Installation

In hubot project repo, run:

`npm install hubot-bangbang --save`

Then add **hubot-bangbang** to your `external-scripts.json`:

```json
[
  "hubot-bangbang"
]
```

## Configuration

**hubot-bangbang** uses [hubot-auth](https://github.com/hubot-scripts/hubot-auth) and is configured via the following environment variables:

* `HUBOT_BANGBANG_COMMANDS_FILE` -- File to load executable commands from; see below for file format.
* `HUBOT_BANGBANG_TIMEOUT` -- Timeout for shell executions of commands; default is `10000`.
* `HUBOT_BANGBANG_LOG_LEVEL` --  Log level, default is `info`.
* `HUBOT_BANGBANG_ROLE` -- If set, auth role required to interact with Bosun. Default is `bangbang`.
* `HUBOT_BANGBANG_SLACK` -- If `yes` enables rich text formatting for Slack, default is `no`.

## Commands File Format

**hubot-bangbang** executes pre-defined shell commands. These commands are defined by a commands file which is passed via the environment variable `HUBOT_BANGBANG_COMMANDS_FILE` to **hubot-bangbang**. The file must contain a JSON object array of zero or more objects. The file may be modified and reloaded during the runtime of hubot. See the [Commands](#Commands) section for details.

For each object, the following keys are used:

* `name` -- name of the command (mandatory)
* `description` -- description of the command; used in some Hubot replies (mandatory)
* `regex` -- the regular expression used by Hubot to recognize the command; may contain capture groups useful for parameters (mandatory)
* `exec` -- the shell command to execute; may use `$n` with _n in [1..]_ to address capture groups; (mandatory)
* `output_type` -- the format to set the output in; valid alternatives are `markdown, pre, plain, ignore` (mandatory)
* `timeout` -- timeout for shell execution; defaults to environment variable `HUBOT_BANGBANG_TIMEOUT` (optional)
* `role` -- if set, a user must have this role in addition to
* `HUBOT_BANGBANG_ROLE`; allows the admin to protect some commands with additional access control (optional)

### Output Formats

The output may be formatted in different styles. This is especially useful when **hubot-bangbang** is used with Slack. The following format alternatives may be used:

* `markdown` -- The output is already Markdown formatted and will be passed as Markdown to Slack.
* `pre` -- The output format is plain text, but will formatted as _pre-formatted code block_. This means, the output will be surrounded by _```_ and passed as Markdown to Slack.
* `plain` -- The output is passed unmodified as plain text.
* `ignore` -- The output is ignored.

### Example

In the example below, there are two commands. The first command, _date_, specifies the mandatory keys only. The second command, _use report_, retrieves a [USE report](https://github.com/lukaspustina/use_report) from a remote server. Since the report is formatted in Markdown, the command will pass the output as Markdown to Slack for a pretty presentation. In order to retrieve a use report, the user must posses both roles, _bangbang_ as well as _bangbang.use_report_.

```json
[
  {
    "name": "date",
    "description": "retrieve local date from the specified host",
    "regex": "get date for (.+)",
    "exec": "echo ssh $1 date",
    "output_type": "plain"
  },
  {
    "name": "use report",
    "description": "retrieve an USE report from the specified host",
    "regex": "get use report for (.+)",
    "exec": "ssh $1 usereport.py",
    "output_type": "markdown",
    "timeout": 60,
    "role": "bangbang.use_report"
  }
]

```

## Commands

**hubot-bangbang** process two types of commands. General commands are used to interact with **hubot-bangbang** and are shown when Hubot is asked for help. Shell commands are load from the commands file. In order to run a shell command, first you have type the prefix `!!` followed by a space and then the a command that is recognized by one of the regular expressions defined for the shell commands.

### General Commands

* `show bangbang commands `-- Shows currently available shell commands.
* `reload bangbang commands` -- Reloads shell commands definition from commands file.

### Shell Commands

You can run the above commands like this:

> @hubot !! get date for www.test.com

and

> @ubot !! get use report for www.test.com

## Sample Interaction

```
```

## NPM Module

https://www.npmjs.com/package/hubot-bangbang
