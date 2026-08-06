Use `set -euo pipefail`.

Be very careful with using `rm` and other destructive commands.

Prefer simple shell idioms- require a lower level of bash proficiency for reviewers.

When functions are being written, question whether shell should be used.
Functions can end up interacting poorly with `set -e`

Write tests.
