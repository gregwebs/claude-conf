See README.md for an overview of the project

## Code Quality Guidelines
- **DRY**: Avoid code duplication. Use variables, functions, and modules to share code
- **Types**: Use strong typing. For example, after a string is validated/parsed it should be given a new type.
- **Testing**: Refactor code into small testable functions. Write lots of tests without using mocks.
- **Error Handling**: Use Result/Option. Do not ignore errors. An error should be passed up callers until it reaches an error handler that properly handles the error by terminating the program in an exit state or returning an HTTP error code.
- **Constants**: Define thresholds and parameters as named constants
- **Documentation**: Comments state design constraints, invariants, and why. Not what the code does. Do not write comments that restate what the next line does. write or refactor code to make what it is doing easier to understand
- **Tracing**: Add lots of debug level logging statements. Programs should be able to set the log level via an environment variable or CLI. Info level statements should show what is happening in the program at a high level.

## Agent Review
Reviews should be done be the engineeering-lead agent defined in .claude/agents/engineering-lead.md

# Workflow
- update the local main to the latest from origin and branch from that.
- Planning
  * Create a plan
    * Describe the changes at different levels of detail
      * start with the high-level architecture of the changes
      * end with code implementation details
    * Create state diagrams for all state changes
      * This can be done with ascii tables, art, or an html artifact
    * Suggest breaking larger changes into iterative steps
    * Describe the future phases of coding (including tests and documentation) and verification, 
  * get feedback and rework the plan
    * Perform an Agent Review of any new features or non-trivial bug fixes
  * get approval before implementing
- Changing data
  * When updating database data, first create a backup of the existing database
- Coding
  * When deviating from the plan, ask for approval
  * Write tests before writing code and run tests frequently
  * Check the code using `cargo check` as frequently as possible
  * Run `just lint` and resolve all warnings
  * Documentation
    * Update and add technical documentation. It should be accessible by following links from the README.md
    * there should be one canonical place where something is documented (besides ./docs/change which is a snapshot in time)
      * check for references between documentation
    * Add state change diagrams to documentation
    * Put information from this change into a file in ./docs/change
      * If older change documentation is outdated, remove it.
- Code review
  * Perform an Agent Review before verification
    * Do a follow up Agent Review of any changes made during verification
- Verification
  * verify manually that the changes work as expected in the application
  * start up a server on a separate port with a separate test database `--db` and a separate `--workdir` directory for saving concert information
  * test edge cases and failure modes in addition to the happy path
  * use Playwright to confirm visual/interaction aspects of the UI
    * maintain playwright scripts as e2e tests. this is only necessary where Foldkit tests are not adequate.
- Pull request
  * Prepare a pull request. For the commit and PR description point to what is added in ./docs/change 
