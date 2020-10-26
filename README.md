# secure_env_vars

Run a command or script with sensitive environment variables.

## Table of Contents

- [Description](#description)
- [Parameters](#parameters)
- [Usage](#usage)
  - [Setting the environment variables](#setting-the-environment-variables)
  - [Running a command](#running-a-command)
  - [Running a script](#running-a-script)

## Description

This module includes a single plan, `secure_env_vars`, which can be used to run
a command or script on a list of targets with sensitive environment variables.

This is useful if you need to set environment variables on a target, but do not
want to hard-code the values for the variables into your plan, as they contain
sensitive information. Instead, Bolt will load the environment variables by
reading the `BOLT_ENV_VARS` environment variable and parse it as JSON. The value
of this environment variable should be a JSON object that maps environment
variable names to values.

## Parameters

### `targets`

The targets to run the command or script on.

- **Type:** `Boltlib::TargetSpec`

### `command`

The command to run.

- **Type:** `String`

### `script`

The script to run.

- **Type:** `String`

## Usage

This plan can be used to run either a command or a script, but not both at
the same time. If you provide both a `command` and `script` parameter, the
plan will error.

### Setting the environment variables

To set the environment variables that will be used by the command or script,
set the `BOLT_ENV_VARS` environment variable to a JSON representation of a
map of environment variable names to values.

For example, if you need to set the `SECRET_PASSWORD` environment variable
for your command or script:

```shell
export BOLT_ENV_VARS='{"SECRET_PASSWORD":"$uper$ecretP@ssword!"}'
```

### Running a command

To run a command, set the `command` parameter.

_\*nix shell command_

```shell
bolt plan run secure_env_vars targets=servers command="git pull https://$OAUTH_TOKEN:x-oauth-basic@github.com/name/repo.git master"
```

_PowerShell cmdlet_

```powershell
Invoke-BoltPlan -Name secure_env_vars targets=servers command="git pull https://$OAUTH_TOKEN:x-oauth-basic@github.com/name/repo.git master"
```

### Running a script

To run a script, set the `script` parameter. This can be either a relative path,
absolute path, or a file from a module (e.g. `modulename/script.sh`).

_\*nix shell command_

```shell
bolt plan run secure_env_vars targets=servers script=scripts/configure.sh
```

_PowerShell cmdlet_

```powershell
Invoke-BoltPlan -Name secure_env_vars targets=servers script=scripts/configure.ps1
```
