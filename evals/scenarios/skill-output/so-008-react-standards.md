---
id: SO-008
dimension: skill-output
skill: react-standards
name: Enforce React TypeScript coding standards
pass_threshold: 0.70
scoring: skill-output-judge
fixture: fixtures/ReactStandardsCheck.tsx
---

# SO-008: Enforce React TypeScript Coding Standards

## Task

> Review this React component for coding standards compliance.

```tsx
import React, { useState, useEffect } from 'react';

export default function UserProfile(props: any) {
  const [user, setUser] = useState(null);
  const [loading, setLoading] = useState(false);

  useEffect(() => {
    setLoading(true);
    fetch('/api/users/' + props.userId)
      .then(res => res.json())
      .then(data => {
        setUser(data);
        setLoading(false);
      });
  }, []);

  const handleDelete = () => {
    fetch('/api/users/' + props.userId, { method: 'DELETE' });
    window.location.href = '/users';
  };

  if (loading) return <div>Loading...</div>;

  return (
    <div onClick={handleDelete}>
      <img src={user.avatar} />
      <span>{user.name}</span>
      <span style={{color: 'red'}}>{user.email}</span>
    </div>
  );
}
```

Activate the `react-standards` skill to check this code.

## Expected Findings

| Issue | Severity | Standard |
|-------|----------|----------|
| `props: any` — no typed props interface | HIGH | Always define prop types |
| `useState(null)` without type parameter | MEDIUM | Use `useState<User \| null>(null)` |
| Missing `props.userId` in useEffect dependency array | HIGH | Exhaustive deps rule |
| No error handling on fetch calls | HIGH | Handle network errors |
| String concatenation for URL (potential injection) | MEDIUM | Use template literals or URL builder |
| `handleDelete` has no confirmation | HIGH | Destructive action without user confirmation |
| `window.location.href` navigation (not React Router) | MEDIUM | Use router navigation |
| `<div onClick={handleDelete}>` — non-semantic click handler | HIGH | Use `<button>` for interactive elements (a11y) |
| `<img>` without alt attribute | HIGH | Accessibility requirement |
| Inline styles instead of CSS modules/Tailwind | LOW | Use design system classes |

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Identifies `any` type issue | 15% | Mentions props typing |
| Identifies missing useEffect dependency | 15% | Mentions dependency array gap |
| Identifies no error handling on fetch | 15% | Mentions unhandled promise/error |
| Identifies accessibility issues (img alt, div onClick) | 20% | Mentions at least one a11y issue |
| Identifies destructive action without confirmation | 15% | Mentions handleDelete risk |
| Suggests specific fixes | 20% | Provides concrete code improvements |

**Critical failure:** Approves the code as standards-compliant.
