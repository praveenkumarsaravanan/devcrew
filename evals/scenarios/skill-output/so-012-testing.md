---
id: SO-012
dimension: skill-output
skill: testing
name: Generate tests for a service class
pass_threshold: 0.70
scoring: skill-output-judge
---

# SO-012: Generate Tests for a Service Class

## Task

> Write tests for this service class:

```java
@Service
public class PaymentService {
    private final PaymentGateway gateway;
    private final PaymentRepository repository;
    private final EventPublisher events;

    public PaymentService(PaymentGateway gateway, PaymentRepository repository, EventPublisher events) {
        this.gateway = gateway;
        this.repository = repository;
        this.events = events;
    }

    public PaymentResult processPayment(PaymentRequest request) {
        if (request.getAmount() <= 0) {
            throw new IllegalArgumentException("Amount must be positive");
        }
        if (request.getAmount() > 10000) {
            throw new PaymentLimitExceededException("Amount exceeds single transaction limit");
        }

        GatewayResponse response = gateway.charge(request.getCardToken(), request.getAmount());

        Payment payment = Payment.builder()
            .orderId(request.getOrderId())
            .amount(request.getAmount())
            .status(response.isSuccess() ? PaymentStatus.COMPLETED : PaymentStatus.FAILED)
            .gatewayReference(response.getReference())
            .build();

        repository.save(payment);
        events.publish(new PaymentProcessedEvent(payment));

        return new PaymentResult(payment.getStatus(), payment.getGatewayReference());
    }
}
```

Activate the `testing` skill.

## Expected Behavior

1. Uses the project's test framework conventions (JUnit 5 + Mockito).
2. Tests the happy path (successful payment).
3. Tests validation boundaries (amount ≤ 0, amount > 10000).
4. Tests the failure path (gateway returns failure).
5. Verifies side effects (repository.save called, event published).
6. Uses descriptive test method names.
7. Does NOT test implementation details (private methods, field access).

## Scoring

| Criterion | Weight | Pass |
|-----------|--------|------|
| Happy path test | 15% | Successful payment flow tested |
| Validation boundary tests (≤0, >10000) | 20% | Both boundaries covered |
| Failure path test (gateway failure) | 15% | Failed gateway response tested |
| Side effect verification (save + event) | 20% | Both verify calls to repository and events |
| Follows framework conventions (JUnit 5, Mockito) | 15% | Uses @Test, @Mock, proper assertions |
| Descriptive test names | 15% | Names describe the scenario, not "test1" |

**Critical failure:** Tests that would not compile or that test only trivial cases (e.g., constructor not null).
