---
name: code-review-with-followup
description: "Adversarial code review with explicit followup instructions"
---

Perform an **adversarial** `/code-review`.
Persist findings as `code-review.md`.

Give a fresh `implementer` sub-agent `code-review.md` along with what was reviewed.
Ask the `implementer` to make changes and provide an explanation for them as `code-review-followup.md`

Perform a non-adverarial followup review for `code-review-followup.md` and a diff of the followup changes that were made. Have the `implementer` address any further followup changes needed.
