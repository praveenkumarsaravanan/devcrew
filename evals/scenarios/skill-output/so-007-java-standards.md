---
id: SO-007
dimension: skill-output
skill: java-standards
name: Enforce Java Spring coding standards
pass_threshold: 0.70
scoring: skill-output-judge
fixture: fixtures/JavaStandardsCheck.java
---

# SO-007: Enforce Java Spring Coding Standards

## Task

> Review this Java service class for coding standards compliance.

```java
package com.example.service;

import java.util.*;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

@Service
public class OrderService {

    @Autowired
    private OrderRepository orderRepository;

    @Autowired
    private PaymentService paymentService;

    public Order createOrder(Map data) {
        Order order = new Order();
        order.setCustomerId((String) data.get("customerId"));
        order.setAmount((Double) data.get("amount"));
        order.setItems((List) data.get("items"));

        if (order.getAmount() > 0) {
            paymentService.charge(order.getCustomerId(), order.getAmount());
        }

        return orderRepository.save(order);
    }

    public void deleteAllOrders() {
        orderRepository.deleteAll();
    }
}
```

Activate the `java-standards` skill to check this code.

## Expected Findings

| Issue | Severity | Standard |
|-------|----------|----------|
| Wildcard import (`java.util.*`) | MEDIUM | Use explicit imports |
| Field injection (`@Autowired`) instead of constructor injection | HIGH | Use constructor injection for testability |
| Raw types (`Map`, `List`) without generics | HIGH | Always use parameterized types |
| Unsafe casts without null/type checking | HIGH | Validate before casting |
| `deleteAllOrders()` with no safeguard | HIGH | Destructive operations need confirmation or soft-delete |
| No input validation on `createOrder` | MEDIUM | Validate inputs before processing |
| No transaction annotation | MEDIUM | `createOrder` modifies state and calls external service |

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Identifies constructor injection issue | 20% | Mentions @Autowired field injection |
| Identifies raw type / generics issue | 20% | Mentions Map/List without type params |
| Identifies unsafe cast issue | 15% | Mentions ClassCastException risk |
| Identifies destructive deleteAll risk | 15% | Mentions lack of safeguard |
| Identifies missing validation | 15% | Mentions input validation gap |
| Suggests specific fixes (not just "fix it") | 15% | Provides concrete alternatives |

**Critical failure:** Approves the code as standards-compliant.
