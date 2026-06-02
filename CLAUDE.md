See README.md for an overview of the project

## Code Style Guidelines

## Code Quality Guidelines
- **DRY**: Avoid code duplication. Use variables, functions, and modules to share code
- **Types**: Use strong typing where possible. For example, after a string is validated/parsed it should be given a new type.
- **Testing**: Refactor code into small testable functions. Write lots of tests without using mocks.
- **Constants**: Define thresholds and parameters as named constants
- **Documentation**: When the purpose of code is not easy to determine, document it. First try to make the purpose easier to understand.
- **Tracing**: Add lots of debug level logging statements. Programs should be able to set the log level via an environment variable or CLI. Info level statements should show what is happening in the program at a high level.
- **Error Handling**: Do not ignore errors. An error should be passed up callers until it reaches an error handler that properly handles the error by terminating the program in an exit state, returning an HTTP error code, etc.

# Workflow
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
    * Have engineering-lead review any new features or non-trivial bug fixes
  * get approval before implementing
- Changing data
  * When updating data, first create a backup of the existing data
- Coding
  * When deviating from the plan, ask for approval
  * Write tests before writing code and run tests frequently
  * Check the code using `cargo check` as frequently as possible
  * Documentation
    * Update technical documentation
    * Add state change diagrams to documentation
    * Create any new documentation files that are needed
- Code review
  * Have engineeering-lead do a code review before verification
    * Do a follow up review of the changes made during verification
- Verification
  * verify manually that the changes work as expected in the application by running
    * make sure the application can be ran with copied data and/or in a dry run mode
      * existing data in use should no be changed
      * notifications should not be sent out (unless there is a notification channel specifically for testing)
  * test edge cases and failure modes in addition to the happy path