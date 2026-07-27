---
name: grilling
description: Grill the user relentlessly about a plan, decision, or idea. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a design tree: every decision branches into the decisions that hang off it.

Every question should also provide your recommended answer. End questions with: "Do you agree with the recommendation?"

Work the tree in **rounds**. The **frontier** is every decision whose prerequisites are already settled or will be settled by a simple "yes" answer. The questions you can ask _now_ without guessing at answers you haven't heard yet other than "yes".

Ask the questions in the round one at a time. Asking multiple questions at once is bewildering.
Each next question in the round should be asked immediately.
If the user answers a question with "yes" or if the next question has absolutely no dependency on prior round responses, the round continues. Otherwise the round ends early so you can take time to understand the user's response.

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them. Recompute the frontier and ask the next round. A question whose answer depends on another question (other than a simple "yes") still open in this round belongs to a _later_ round, not this one.

Finding facts is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), dispatch a sub-agent to find it — don't ask the user for anything you could look up yourself. Don't block on it: a running exploration is an unsettled prerequisite, so only the questions downstream of it wait for the sub-agent to report — ask the rest of the frontier now. The decisions are the user's — put each to them and wait.

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.
