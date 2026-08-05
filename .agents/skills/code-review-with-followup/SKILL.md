---
name: code-review-with-followup
description: "Adversarial code review with explicit followup instructions"
---

Have a `reviewer` sub-agent perform an **adversarial** `/code-review`.
Persist findings as `code-review.md`.

If there are no findings in review (rare unless the changes is trivial), code review is complete.
Otherwise, we do a followup.

Give an `implementer` sub-agent `code-review.md` along with what was reviewed.
Ask the `implementer` to make changes and provide an explanation for them as `code-review-followup.md`

Have the `reviewer` sub-agent perform a followup review of how concerns in `code-review.md` were addressed by `code-review-followup.md` and a diff of the followup changes. Have the `implementer` address any further followup changes needed.
