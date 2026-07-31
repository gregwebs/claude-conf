Important Documentation

* README.md for a starting point
* Discover additional applicable standards documents when they apply such as `CONTRIBUTING.md` and `CODING_STANDARDS.md`.

# Tool Usage

## Curl

/usr/bin/curl may have TLS issues. Use /opt/homebrew/opt/curl/bin/curl if available.

## Github

If the /github-app skill is availble and configured:
* Use it for access to the Github repo.
* Even if you don't need to auth, still use that skill because it allow lists scripts for the interaction patterns we used.

#### Github Actions CI

If the /github-actions-ci skill is available, use it for interactions with Github CI.

## Temporary file handling for Codex

- `/private/tmp` is an approved writable location.
- Create throwaway test harnesses and diagnostic artifacts there without asking permission.
  Do not request escalation merely to read or write `/private/tmp`.
- Prefer `mktemp -d /private/tmp/tiny-desk-splitter.XXXXXX` for isolated temporary work.
- Use a direct-write repository script for temporary Markdown bodies.
- Do not use `apply_patch` for temporary files; reserve it for repository edits.

## Shell command execution

Run approved repository scripts directly- do not prefix these commands with zsh -lc, env, PATH=..., or similar wrappers unless the command cannot run directly. Only use `/bin/zsh -lc` when shell syntax, environment assignment, or a multi-command pipeline is strictly required.
If an environment adjustment is required, see if the shell scripts can be updated so that the adjustment is no longer needed.

Use allow listed commands from skills and settings.

If commands that you run require approval, propose writing a script for that which can be permanently allow listed.

## Documentation

There should be one canonical place where something is documented.
Check on references between documents.
Cull out of date documentation.

Update and add lasting technical documentation. It should be accessible by following links from the README.md.
Documentation should explain things that are not readily available from reading the code, for example:
* useful commands to run (but if they are more than a one liner codify it by addint it to the project script directory)
* purpose and product needs
* technical design trade offs considered (important ones belong in ./docs/adr)

Add diagrams when they make a relationship or an operation materially clearer.

# Workflows

## General

- Update the local copy to the latest from origin and use a branch
- /implement the changes using workflow component sections described below


## Bug Investigation

If a bug is non-trivial, use /diagnosing-bugs to investigate it.

Generate a root cause analysis of the defect.
A simple straightforward root cause and fix can be implemented immediately without a ticket.
Otherwise,
* Save the root cause analysis on the ticket for the defect.
* If there is no ticket, create one using /to-tickets.
  * Suggest how to fix the defect on the ticket, but the main focus is on root cause analysis.
