# Go

## Error handling

Always handle errors. Logging errors is not handling them. There are few exceptions:
* deferrerd closing of resources- it is often safe to log the error at a warning level without returning it.
* some APIs return errors for expected (non-error) outcomes (for example EOF). We need to make sure we check the error type and handle the other errors

Avoid using panic/recover if possible.
In stateless servers, a panic for one request should not crash the program but should be reported as an error.

If a for loop has multiple continue statements where errors are collected, consider refactoring to call a function and have just one continue statement.

## HTTP
 
* Client retries: use failsafe Go [github.com/failsafe-go/failsafe-go](https://failsafe-go.dev/http/)
* Always check the HTTP error code
* Log requests and responses when there is an HTTP error unless the information is sensitive and there are no redaction facilities

## CLI options

Use github.com/alexflint/go-arg for CLI argument parsing.
If the options are very simple, the standard library flags can be used.

## Newtype pattern

Instead of using raw Golang types, we should often use a new type.
Parse, don't validate, and help ensure that with a simple new type.

```go
type ProductName string
```

## Linting

Write code that passes standard linters. Use `.golangci.yml`.

## Nesting

Avoid nesting code; keep the "happy path" to the left

### Context

Accept `context.Context` as first parameter in functions that perform I/O or long-running operations.
Do not store contexts in structs or pass a nil context.
Avoid storing values in the context unless the value should be (request) scoped for context usage.

### Logging

Use structured logging with slog.
Never log sensitive data- sanitize before logging or placing into errors.
The user should be able to specify a log level via a CLI option or env variable.

### Testing

Use `t.Helper()` to improve failure reporting.
avoid `time.Now()` and other non-deterministic testing.

### Documentation

When writing examples, use an `Example` function instead of doc comments.
