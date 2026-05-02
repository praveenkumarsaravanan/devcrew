# DevCrew: How Do You Know Your AI Tools Actually Help Your Team?

Your team adopted AI coding assistants six months ago. Developers say they feel faster. PRs seem to land sooner. But when someone asks "how much has code quality improved?" the room goes quiet. Nobody measured. Nobody knows.

This is the vibes problem. Teams evaluate AI tooling the same way they evaluate office snacks -- by gut feel. The engineering manager thinks the AI code reviewer is catching bugs. The tech lead believes the workflow produces better test coverage. The developer insists the memory feature saves time. None of them can point to a number.

The gap between "cool demo" and "production-grade tooling" is not capability. It is measurement. I built an evaluation framework for [DevCrew](https://github.com/praveenkumarsaravanan/devcrew) -- my open-source AI engineering team -- specifically to close that gap. This article covers what I measure, how I measure it, and what I learned in the process.

This is the third article in a series. The first, [Turning Your AI-Powered IDE Into a Complete Engineering Team](turning-ide-into-engineering-team.md), covers the multi-agent workflow architecture. The second, [Write Once, Agent Everywhere](distributing-ai-tooling.md), covers packaging and distribution across IDEs and teams. This piece covers how I prove any of it actually works.

---

## Why Measuring AI Tooling Is Hard

Standard software testing has a clear model: given this input, expect this output. AI tooling breaks that model in three ways.

**Non-determinism is the default.** Even with temperature set to zero, LLM outputs vary by up to 15% in accuracy across identical runs, and 47--75% of coding tasks produce different outputs across requests ([Ouyang et al., arXiv:2408.04667](https://arxiv.org/abs/2408.04667)). Run your AI code reviewer on the same file today and tomorrow -- you may get different findings. A test suite that passes on Monday and fails on Tuesday is not a test suite; it is a coin flip.

**There is no ground truth for "good code review."** Unlike image classification, where the cat is either in the photo or it is not, software quality is multi-dimensional and partially subjective. A review that catches a SQL injection but misses a race condition -- is that good? It depends on the context. Without a defined standard of what "good" means, measurement is impossible.

**Value compounds across phases.** The benefit of thorough requirements clarification does not appear immediately. It shows up three phases later as fewer rework cycles, and five phases later as tests that actually trace back to what the user asked for. Measuring any single phase in isolation understates the system's contribution and overstates its cost.

The temptation, given these challenges, is to measure what is easy: tokens processed, response time, lines of code generated. These are activity metrics. They tell you nothing about whether the code is correct, secure, or maintainable. A developer who generates 500 lines of vulnerable code faster is not more productive -- they are more dangerous.

---

## What to Actually Measure

I structured DevCrew's evaluation around six behavioral dimensions. Each maps to a question that a team lead, engineering manager, or CTO would actually ask.

| Dimension | The Question | Why It Matters |
|-----------|-------------|---------------|
| **Right-sizing** | Does the tool skip unnecessary ceremony for small tasks? | A typo fix that triggers a full architecture review wastes everyone's time. Developers bypass the workflow entirely, losing all guardrails. |
| **Quality gates** | Does the code reviewer catch real bugs? | If the AI reviewer approves a SQL injection, it is worse than no review -- it creates false confidence. |
| **Memory** | Does it remember what you told it yesterday? | Re-explaining your tech stack, task tracker, and deployment target every session is a tax on every interaction. |
| **Governance** | Does it escalate risky changes correctly? | An AI that autonomously modifies authentication logic is a liability. One that blocks on a config formatting change is a bottleneck. |
| **Consistency** | Does it produce similar results across runs? | If Tuesday's review catches 6 bugs and Wednesday's catches 2 on the same file, the tool is unreliable. |
| **Skill output** | Do individual capabilities produce correct results? | A commit message generator that violates your own naming conventions undermines the standards it is supposed to enforce. |

These are not theoretical. Each dimension has a pass threshold, a set of scenarios, and a scoring method. Right-sizing must hit 80% classification accuracy. Quality gates require 70% recall on planted bugs and 100% recall on critical bugs. Memory requires 90% accuracy on context value loads. Governance requires 100% accuracy on the critical path. If any dimension fails its threshold, the system is not ready.

---

## Standard Metrics, Not Vibes

The key insight is that agent behavior evaluation is a classification problem. The reviewer classifies code as "has a bug" or "does not have a bug." The scope classifier assigns a category: quick fix, standard change, or full feature. The governance engine labels risk: low, medium, or high. Once you frame it this way, standard ML metrics apply directly.

**Accuracy** measures overall correctness. Of all the classifications the system made, what fraction were right? Right-sizing accuracy is the percentage of tasks where the predicted scope matches the expected scope. Memory accuracy is the percentage of persisted values loaded correctly without re-asking.

**Precision and Recall** matter most for quality gates. Of all the bugs the reviewer flagged, how many were real? That is Precision. Of all the real bugs, how many did the reviewer find? That is Recall. Both must be high -- and understanding why requires a specific example.

I created two fixture files with planted bugs as ground truth: an `AuthService.java` with 6 known security bugs (SQL injection, plaintext password comparison, missing rate limiting, predictable tokens, information disclosure, no input validation) and a `PaymentForm.tsx` with 5 known bugs (PII logging, XSS via `dangerouslySetInnerHTML`, no input sanitization, missing accessibility labels, performance issues). Every bug has a known severity: CRITICAL, HIGH, MEDIUM, or LOW.

When the AI reviewer analyzes `AuthService.java`, I know exactly what it should find. If it flags the SQL injection and the plaintext passwords but misses the predictable token generation, that is 2 true positives and 1 false negative for the HIGH severity category. If it also flags a non-issue -- say, the method naming -- that is a false positive.

A reviewer that flags everything has perfect Recall but terrible Precision. Developers drown in noise and start ignoring findings. A reviewer that flags nothing has perfect Precision (it never flagged a non-issue) but zero Recall -- it missed every bug. **F1 score** -- the harmonic mean of the two -- penalizes either extreme. DevCrew's target is F1 >= 0.75 across all bugs and F1 >= 0.90 for CRITICAL bugs. And there is one hard rule: if the reviewer approves code with a CRITICAL bug, the entire eval scores zero, regardless of everything else.

### Capability Levels

Individual dimension scores are useful, but teams want a single answer: "How mature is this thing?" I defined seven Capability Levels that build on each other:

| Level | Gate | What It Proves |
|-------|------|---------------|
| CL-1 | Classification | Can correctly right-size tasks |
| CL-2 | Quality Detection | Catches known defects reliably |
| CL-3 | Context Persistence | Remembers project context across sessions |
| CL-4 | Governance | Enforces correct autonomy levels on risky changes |
| CL-5 | Consistency | Produces stable results across repeated runs |
| CL-6 | Skill Coverage | Individual skills produce correct output |
| CL-7 | Full Orchestration | All six dimensions pass simultaneously |

CL-1 through CL-2 is minimally viable: the tool classifies tasks correctly and catches bugs. CL-3 through CL-4 is team-ready: it persists context and enforces safety. CL-5 through CL-6 is production-grade: stable and verified. CL-7 means everything passes in a single eval run.

Reporting the highest achieved level gives teams a clear maturity indicator that is more meaningful than a single percentage.

---

## Catching Regressions Before Your Team Does

Capabilities that pass today can break tomorrow. You update a review prompt to be more concise and accidentally weaken its adversarial stance. You refactor a skill and introduce an edge case that causes scope misclassification. You upgrade the underlying model and the memory loading behavior changes.

This is the same problem that test suites solve for application code. You would not ship a backend service without running its tests. Why would you ship AI tooling without running its evals?

DevCrew's evaluation framework defines five Regression Levels:

| Level | Name | What Happened | Merge Policy |
|-------|------|--------------|--------------|
| RL-0 | No regression | All scores stable | Safe to merge |
| RL-1 | Score degradation | A dimension score dropped > 10% | Merge with investigation note |
| RL-2 | Threshold breach | A passing dimension now fails its threshold | Fix before merge |
| RL-3 | Capability loss | A previously achieved CL no longer passes | Block merge |
| RL-4 | Critical regression | A new critical failure appeared | Block merge |

RL-1 is a yellow flag -- something got worse, but nothing broke. Document why and move on. RL-2 means a feature that worked now does not. RL-3 and RL-4 block merges entirely. If version 1.5 achieved CL-4 (Governance) and version 1.6 drops to CL-3, something in governance broke and must be fixed before release.

The protocol is simple: establish a baseline by running the full suite, make your changes, re-run the suite, and compare. Flag any score drop greater than 1 point on the 0--5 scale per scenario, any threshold breach per dimension, any lost Capability Level, and any new critical failure. Classify the highest Regression Level triggered.

---

## What This Looks Like in Practice

A concrete example. Scenario QG-001 tests whether DevCrew's code review catches security bugs:

1. Place `AuthService.java` (6 planted bugs: 2 CRITICAL, 2 HIGH, 2 MEDIUM) in a test project.
2. Ask DevCrew: "Review AuthService.java for security issues and code quality."
3. DevCrew classifies the task as HIGH risk (auth service), spawns an isolated Backend Reviewer subagent, and produces a review.
4. A separate LLM-as-judge compares the review output against the known bug list. It computes true positives, false positives, and false negatives.
5. Result: Precision = 0.83, Recall = 0.83 (5 of 6 bugs caught), F1 = 0.83, Critical Recall = 1.0 (both CRITICAL bugs found). Verdict: reject code. **Pass.**

The same process runs across 30+ scenarios spanning all six dimensions. The full suite takes about an hour and produces a scored report with per-dimension breakdowns, aggregate scores, Capability Level, and Regression Level.

> **Browse the framework:** The complete eval suite -- scenarios, fixtures, judges, rubrics, and metrics -- is in the [`evals/` directory](https://github.com/praveenkumarsaravanan/devcrew/tree/trunk/evals).

---

## Lessons Learned

**Measure outcomes, not activity.** Lines of code generated, tokens processed, and response time are vanity metrics. Bugs caught, requirements traced, rework cycles avoided -- these tell you whether the tool is making your team better or just faster at producing problems.

**Ground truth is expensive but essential.** Creating `AuthService.java` with 6 planted bugs and `PaymentForm.tsx` with 5 planted bugs took real effort. Each bug needed a known severity and a specific location. But without ground truth, Precision and Recall are impossible to compute. You are back to vibes.

**Evals drift too.** The evaluation suite itself needs maintenance. When you add a new skill, you need a corresponding scenario. When you change a threshold, you need to re-baseline. When the underlying model changes behavior, previously stable scenarios may need recalibration. Treat your eval suite like you treat your test suite -- it is living infrastructure, not a one-time artifact.

**Start with the dimension that matters most.** You do not need all six dimensions on day one. If your primary concern is "does the reviewer catch security bugs?" -- start with quality gates. If your concern is "does the tool waste time on small tasks?" -- start with right-sizing. Add dimensions as you build confidence.

---

## Conclusion

The trilogy is complete. [Article 1](turning-ide-into-engineering-team.md) described how to build an AI engineering team with subagent isolation, adversarial review, and structured handoffs. [Article 2](distributing-ai-tooling.md) described how to package and distribute it across IDEs and teams. This article described how to prove it works -- with standard ML metrics, planted-bug fixtures, Capability Levels, and regression detection.

The uncomfortable truth is that most teams shipping AI tooling today have no way to answer the question "does this actually help?" They adopted the tools, felt good about the demos, and moved on. The tools may be excellent. They may also be approving SQL injections while the team believes they have a security review process.

Measurement is the difference between hope and confidence. Build your eval suite. Plant your bugs. Compute your F1. Know your Capability Level. And when someone asks whether your AI tools actually help your team, have a number ready.

[DevCrew](https://github.com/praveenkumarsaravanan/devcrew) is open source -- including the [evaluation framework](https://github.com/praveenkumarsaravanan/devcrew/tree/trunk/evals). Adapt it to your tools, your team, and your standards.
