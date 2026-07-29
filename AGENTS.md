* README.md for an overview of the project
* CONTRIBUTING.md for development instructions
* CODING_STANDARDS.md for how to write code

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


# General workflow

- update the local copy to the latest from origin and use a branch
- /implement the changes using workflow component sections described below
  - **Documentation**
  - **Verification**
- send a /pull-request

# Workflow Components

## Documentation

In code:
* Don't document *what* code does. Rewrite code to make what it does self-documenting.
* Document *why* code does what it does and alternative approaches that were purposefuly not taken.

There should be one canonical place where something is documented.
Check on references between documents.
Remove out of date documentation.

Add diagrams to documentation.

Update and add lasting technical documentation. It should be accessible by following links from the README.md.
Documentation should explain things that are not readily available from reading the code, for example:
* useful commands to run (but if they are more than a one liner codify it by addint it to the project script directory)
* purpose and product needs
* technical design trade offs considered (important ones belong in ./docs/adr)


## Verification

Verify manually that the changes work as expected in a live application.
Test edge cases and failure modes in addition to the happy path.
Look at the **Implementation Plan** for verification tests to peform.
Follow CONTRIBUTING.md for instructions on how to run the program for verification.

Start up a server on a separate port with a separate test database `--db` and a separate `--workdir` directory for saving concert information
When there are backend changes, first test the API.
Use Playwright to confirm visual/interaction aspects of the UI.
Consider whether any manual verification steps should be added as automated tests.

Don't make any changes to data that cannot be undone.
When updating database data, first create a backup of the existing database.

## Bug Investigation

If a bug is non-trivial, use /diagnosing-bugs to investigate it.

Generate a root cause analysis of the defect.
A simple straightforward root cause and fix can be implemented immediately without a ticket.
Otherwise,
* Save the root cause analysis on the ticket for the defect.
* If there is no ticket, create one using /to-tickets.
  * Suggest how to fix the defect on the ticket, but the main focus is on root cause analysis.
