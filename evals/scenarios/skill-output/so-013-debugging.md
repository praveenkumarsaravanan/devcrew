---
id: SO-013
dimension: skill-output
skill: debugging
name: Diagnose a NullPointerException from stack trace
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-013: Diagnose a NullPointerException from Stack Trace

## Task

> We're getting this error in production. Help me debug it.

```
java.lang.NullPointerException: Cannot invoke "String.length()" because "str" is null
    at com.example.service.UserService.normalizeEmail(UserService.java:47)
    at com.example.service.UserService.createUser(UserService.java:23)
    at com.example.controller.UserController.register(UserController.java:35)
    at java.base/jdk.internal.reflect.DirectMethodHandleAccessor.invoke(DirectMethodHandleAccessor.java:103)
    at org.springframework.web.servlet.mvc.method.annotation.RequestMappingHandlerAdapter.handleInternal(...)
```

> The relevant code:
```java
public User createUser(CreateUserRequest request) {
    String email = normalizeEmail(request.getEmail());  // line 23
    // ...
}

private String normalizeEmail(String email) {
    return email.toLowerCase().trim();  // line 47
}
```

Activate the `debugging` skill.

## Expected Behavior

1. Identifies the root cause: `request.getEmail()` returns null, which is passed to `normalizeEmail`.
2. Explains WHY the NPE occurs at line 47 (calling `.toLowerCase()` on null).
3. Distinguishes between the symptom (line 47) and the root cause (line 23 — null email in request).
4. Suggests a fix: null check or validation on the request email field.
5. Suggests a preventive measure: add `@NotNull` / `@Valid` annotation or input validation.

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Correctly identifies null email as root cause | 25% | Points to request.getEmail() returning null |
| Distinguishes symptom vs root cause | 20% | Explains line 47 is symptom, line 23 is cause |
| Suggests immediate fix | 20% | Null check, validation, or default |
| Suggests preventive measure | 20% | Annotation, validation framework, or contract |
| Structured diagnosis (not just "add a null check") | 15% | Explains the chain of events |

**Critical failure:** Suggests fixing line 47 only (treating the symptom, not the cause).
