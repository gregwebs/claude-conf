---
name: document-changes
description: "Record changes in either a PR, issues, docs, or chat output"
---

## Change Record

A Change Record captures an ephemeral implementation moment; it is not lasting
technical documentation.

The ticket or spec has information that should be included or referenced (if linked) for high-level information.

A change record should have additional detail.
If an implementation plan is available, that should include most information needed.
Include technical decisions, pointers to the changed code, completed checklist items, and the
verification performed. Capture follow-on information that would help the next related change.

Use the /explain-changes skill to explain the code changes.

Record a change record in 1 location prioritized according to this order:
* The PR when one is authorized.
* On the issue when an issue tracker is configured
* in an applicable local issue file if local issue files are used
* in an applicable local documentation folder if one is in use
* in the final chat output when no durable location exists
