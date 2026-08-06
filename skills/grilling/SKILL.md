---
name: grilling
description: Grill the user relentlessly - used for planning. Use when the user wants to stress-test their thinking, or uses any 'grill' trigger phrases.
---

Interview the user relentlessly until you reach a shared understanding. Map this as a design tree: every decision branches into the decisions that hang off it.

# Recommendation

All questions have a recommended answer.
Most questions have alternative answers.
The reasons for the recommendation and trade-offs with different approaches should be stated succinctly.
Affirming is accepting the recommended answer.

# Question round

The design tree is worked in **rounds**, a set of questions on a related subject.

Questions are identified to the user as ${round_id}.${question_id}. Example session:
* Q: 1.1, A: yes
* Q: 1.2, A: No
* Q: 2.1, etc

# Your job on the main thread

Utilize a separate persistent sub-agent thread to analyze the project and generate questions.
This allows the subagent to come up with the next questions for the round while you are waiting for the user to answer the current question.
Your job is solely to manage the user's grilling session Q&A experience.
The sub-agent will first be tasked with asking the first design question. After that, it will receive user answers and generate new questions.

When presenting a question without any selector menu, always end with "Do you agree with the recommendation?"
If the user's answer is "y", "Y", "Yes", "yes", or "YES!", the recommendation is affirmed.
If you present a selector menu for the user, the recommendation should be default selected response.

Your first priority to present questions with low latency. After launching the sub-agent, your workflow will be:

* Find your next question 
  * If the user affirmed the previous question in the round, and the next question for the round is available, use it immediately
  * Otherwise wait for a next question from the sub-agent
    * While waiting, you can tell the user relevant information that is not part of a question- make it clear that this is not a question.
* Ask a question to the user
* Wait for user's answer
  * While waiting, check for new sub-agent responses
* User answers
* Asynchronously send the response to the sub-agent. Do not wait for a reply.
    

# Communication protocol

## Ids

Ids should use letters rather than numbers.
This distinguishes internal communication from user presentation.

## Answers

includes
* id
* text
* recommendation text
* recommended (boolean)

## sub-agent -> main: question

includes
* type: question
* round id
* round description (only for the first question in a round)
* question id
* subject
* question text
* answers

## main -> sub-agent: answer

includes
* type: answer
* round id
* question id
* recommendation affirmed (boolean)
* answer id (use "N/A" for no answer selected)
* the user's literal answer

## sub-agent -> main: completion

* type: completion
* text (for completion message)

## main -> sub-agent: completion result

* type: completion
* affirmed (boolean)
* the user's literal answer


# Sub-agent job

* generate a new question
* send the new question back asynchronously to the main agent immediately if
  * the question is for the current round and is part of a sequence of affirmative responses
  * the use just completed the prior round and this question is for the new round
  * otherwise, maintain the question locally to be sent later
* check for any new answers, but do not wait unless you are done generating future questions

## Question generation

Each round the user answers reshapes the tree — settled decisions push the frontier outward and unblock questions that depended on them.

Finding facts is your job, never the user's. When a frontier question needs a fact from the environment (filesystem, tools, etc.), find it — don't ask the user for anything you could look up yourself.

### Next question for the round

Prioritize generating new questions for the current round that assume an affirmation. You should generate 3 additional questions into the round unless the round is coming to an end.

If an unanswered question in the current round has multiple good candidate answers then you can generate questions that will be used for non-affirmative answers.

### Next question for future rounds

When you have completed generating next questions for the current round, generate questions for the most likely next round. Follow instructions for the current round.
Next round questions are stored locally and not communicated back to the main agent until the current round completes.

# Completion

The session is done when the frontier is empty: every branch of the design tree visited, nothing left silently assumed. Do not act on it until the user confirms you have reached a shared understanding.

Confirmation is achived via a completion message.
* The sub-agent must send a completion message to the main agent.
* The main agent must end the sub-agent or send a completion response message back.
