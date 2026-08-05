---
name: code-review-with-followup
description: "Adversarial code review with explicit followup instructions"
---

Perform an **adversarial** `/code-review`.
Persist findings as `code-review.md`.

Give a fresh `implementer` sub-agent `code-review.md` along with what was reviewed.
Ask the `implementer` to make changes and provide an explanation for them as `code-review-followup.md`

Have a reviewer sub-agent perform a followup review of how concerns in `code-review.md` were addressed by `code-review-followup.md` and a diff of the followup changes. Have the `implementer` address any further followup changes needed.
