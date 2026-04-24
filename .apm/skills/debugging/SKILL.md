---
name: debugging
description: >
  Systematic error investigation for dev and staging environments. Guides
  through log analysis, stack trace interpretation, root cause isolation, and
  fix verification. Use when a service throws errors, behaves unexpectedly,
  or a test fails for unclear reasons.
---

# Debugging

## Trigger

Activate this skill when:

- The user reports an error, exception, or unexpected behavior in dev or staging
- A test fails and the cause is unclear
- The user shares a stack trace, error message, or log snippet and asks for help
- The user says "debug this," "why is this failing," or "help me figure out what's wrong"
- A build, deployment, or CI pipeline fails with an unclear error

Do NOT activate for production incidents — use the `/incident-response` prompt instead, which includes severity assessment, communication protocols, and escalation paths.

## Workflow

### 1. Gather Evidence

Before hypothesizing, collect facts. Ask the user for any missing items:

| Evidence | How to get it | Why it matters |
|---|---|---|
| **Error message / stack trace** | Terminal output, browser console, CI logs | Points to the failing line and call chain |
| **Steps to reproduce** | User description or test case | Determines if the bug is deterministic |
| **What changed recently** | `git log --oneline -10`, `git diff HEAD~3` | Most bugs are caused by recent changes |
| **Environment** | OS, runtime version, env vars, config | Eliminates environment-specific issues |
| **Expected vs. actual behavior** | User description | Clarifies whether this is a bug, a misunderstanding, or a config issue |

### 2. Read the Error

Parse the error methodically:

**Stack traces:**
- Start from the **bottom** (the root cause), not the top (the symptom)
- Identify the **first frame in your code** — frames in library code are usually consequences, not causes
- Note the file, line number, and function name of each relevant frame
- Check if the error is in application code, a dependency, or framework internals

**Error types — common patterns:**

| Error Pattern | Likely Cause | First Check |
|---|---|---|
| `NullPointerException`, `TypeError: Cannot read property of undefined/null` | Missing null check, uninitialized variable, failed lookup | Trace the variable back to its assignment |
| `Connection refused`, `ECONNREFUSED` | Dependency not running, wrong host/port | Verify the service is up and the config matches |
| `401 Unauthorized`, `403 Forbidden` | Missing/expired token, wrong credentials, permission issue | Check auth config, token expiry, role assignments |
| `404 Not Found` | Wrong URL, missing route, resource deleted | Compare the URL against the route definitions |
| `500 Internal Server Error` | Unhandled exception in the server | Check server logs for the stack trace |
| `CORS error` | Missing or incorrect CORS headers | Check the server's CORS config and the request origin |
| `Module not found`, `ImportError` | Missing dependency, wrong path, version mismatch | Check `package.json`/`requirements.txt`, run install |
| `Timeout`, `ETIMEDOUT` | Slow dependency, network issue, missing await | Check if the call target is reachable; check for missing async/await |
| `Out of memory`, `heap limit` | Unbounded data, memory leak, missing pagination | Profile memory usage; check for unbounded loops or accumulation |

### 3. Reproduce the Issue

A bug you can't reproduce is a bug you can't fix. Establish reproducibility:

1. **Run the exact command or action** the user described and observe the same error
2. **Simplify** — remove unrelated code, use minimal input, isolate the failing component
3. **Check if it's deterministic** — does it fail every time, or intermittently?
   - **Deterministic:** Proceed to root cause isolation
   - **Intermittent:** Look for race conditions, timing dependencies, external service flakiness, or stale caches

If reproduction fails, the bug may be environment-specific. Compare the user's environment (versions, config, OS) with yours.

### 4. Isolate the Root Cause

Use a systematic process — do not guess-and-check randomly:

**Binary search through the code path:**
1. Identify the entry point (the request, function call, or user action)
2. Identify the failure point (from the stack trace or error log)
3. Add diagnostic logging or breakpoints at the midpoint between entry and failure
4. Determine whether the state is correct at the midpoint
5. Narrow the search: if correct at midpoint, the bug is between midpoint and failure; if incorrect, it's between entry and midpoint
6. Repeat until the root cause is a single operation

**Binary search through time (git bisect):**
When the bug was recently introduced and you don't know which commit caused it:

```bash
git bisect start
git bisect bad                    # current commit is broken
git bisect good <known-good-sha> # last known working commit
# Git checks out the midpoint — test it, then:
git bisect good  # or  git bisect bad
# Repeat until git identifies the first bad commit
git bisect reset
```

**Common root cause categories:**

| Category | Symptoms | Investigation |
|---|---|---|
| **Data issue** | Works with some inputs, fails with others | Compare failing input against working input; check for nulls, unexpected types, encoding |
| **State issue** | Works on first call, fails on subsequent calls | Check for leaked state, uncleaned resources, stale caches |
| **Dependency issue** | Worked yesterday, broken today | Check dependency versions, API changes, service outages |
| **Config issue** | Works locally, fails in CI/staging | Compare env vars, config files, secrets across environments |
| **Concurrency issue** | Intermittent failures, works in isolation | Look for shared mutable state, missing locks, race conditions |
| **Version mismatch** | Import errors, unexpected API behavior | Compare installed versions against expected versions in lock files |

### 5. Fix and Verify

Once the root cause is identified:

1. **Explain the root cause** to the user in plain language — what went wrong and why
2. **Propose a fix** — explain what needs to change and why this fix addresses the root cause
3. **Implement the fix** after user confirmation
4. **Verify the fix:**
   - Re-run the failing scenario — it should now pass
   - Run the full test suite — the fix should not break other tests
   - If the bug was discovered through a test, the test should now pass
5. **Add a regression test** if one doesn't already exist — prevent this bug from recurring

### 6. Report

Summarize the debugging session:

```
## Debugging Summary

**Symptom:** [What the user observed]
**Root cause:** [What actually went wrong and why]
**Fix:** [What was changed to resolve it]
**Regression test:** [Test added/existing test that covers this case]
**Prevention:** [What practice or check would have caught this earlier]
```

## Debugging Toolkit

Use the appropriate tools for the language and environment:

### Log Analysis

```bash
# Search logs for errors
rg "ERROR|WARN|Exception|error|panic" path/to/logs/

# Follow logs in real time
tail -f path/to/service.log | rg "ERROR"

# Filter by correlation ID
rg "req_abc123" path/to/logs/
```

### Runtime Inspection

| Language | Debugger | Quick diagnostic |
|---|---|---|
| Node.js/TS | `node --inspect`, Chrome DevTools | `console.log`, `console.trace()` |
| Python | `pdb`, `ipdb`, PyCharm debugger | `print()`, `traceback.print_exc()` |
| Go | `dlv` (Delve) | `fmt.Printf`, `log.Printf` |
| Java | IDE debugger, `jdb` | `System.out.println`, stack trace logging |
| Browser | Chrome/Firefox DevTools | Console, Network tab, Sources breakpoints |

### Network Diagnostics

```bash
# Test if a service is reachable
curl -v http://localhost:8080/health

# Check DNS resolution
nslookup service-name

# Check if a port is open
nc -zv localhost 5432

# Inspect HTTP requests/responses
curl -i -X GET http://localhost:8080/api/users
```

### Database Diagnostics

```bash
# Check connection
psql -h localhost -U user -d dbname -c "SELECT 1"

# Show running queries (PostgreSQL)
psql -c "SELECT pid, state, query FROM pg_stat_activity WHERE state != 'idle'"

# Check for missing indices (PostgreSQL)
psql -c "SELECT * FROM pg_stat_user_tables WHERE seq_scan > 1000 AND idx_scan = 0"
```

## Guardrails

- **Gather evidence before guessing.** Random changes to "see if it fixes it" waste time and can introduce new bugs. Understand the problem first.
- **Reproduce before fixing.** If you can't reproduce it, you can't verify your fix. Invest time in reproduction.
- **Fix the root cause, not the symptom.** Wrapping code in try/catch to silence an error is not a fix. Identify why the error occurs and address that.
- **One change at a time.** When testing fixes, change one thing and re-test. Multiple simultaneous changes make it impossible to know which one worked.
- **Always add a regression test.** If a bug was worth debugging, it's worth preventing from recurring.
- **Do not fix application bugs in the user's code without confirmation.** Explain the root cause and proposed fix, then let the user decide.

## See Also

- **`/incident-response`** — For production incidents that need severity assessment, communication, and escalation. This skill is for dev/staging debugging.
- **`testing`** — After fixing the bug, use this skill to write a regression test that prevents recurrence.
- **`code-review`** — If the bug reveals a pattern (e.g., missing null checks throughout), a code review can find similar issues elsewhere.
