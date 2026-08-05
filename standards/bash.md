Use `set -euo pipefail`.

Be very careful with using `rm` and other destructive commands.

Prefer simple shell idioms- requiring a lower level of bash proficiency is good.

When functions are being written, question whether shell should be used.
Functions can end up interacting poorly with `set -e`
