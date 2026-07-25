# Assurance Kernel

Formally verified Lean 4 **Certified Transition Algebra** and Assurance Control Plane.

Proof-carrying state transitions, cryptographic evidence lineage, authority bounds, and graceful degradation under assumption failure (v25.7.5).

## Status (v25.7.5)

| Area                          | Status                          |
|-------------------------------|---------------------------------|
| Type safety                   | Excellent                       |
| Transition algebra            | Excellent                       |
| Ledger consistency            | Excellent                       |
| Authority model               | Excellent                       |
| Receipt lineage               | Complete                        |
| State commitment              | Canonical + genuine stateHash   |
| Concrete digest               | Pure-Lean TestDigest            |
| Executable multi-step tests   | Present                         |
| Structural negative checks    | Present                         |
| Regression theorems           | Present                         |
| CI rejecting `sorry`          | Present                         |
| Formal completeness           | ~98%                            |

## Executable Harness

`Assurance/Tests/Smoke.lean` now exercises:

**Positive multi-step sequence**
```
genesis → tickTime → ingestTelemetry → increaseAuthority → tickTime
```

**Structural negative paths** (impossible by construction)
- authority expansion beyond 10 000
- failed state cannot increase authority
- duplicate actionId rejected

## Design Principle

```
Kernel (proved)
      │
      ▼
Digest Interface (typeclass)
      │
      ▼
Concrete Digest Adapter (TestDigest today, SHA-256/BLAKE3 tomorrow)
```

Swapping the digest implementation must never require changes to the transition algebra or its proofs.

## Building & CI

```bash
lake build
```

CI fails on any remaining `sorry`.

## Roadmap remaining

1. ✅ Expanded executable harness (multi-step + negatives)
2. Optional production adapters (SHA-256 / BLAKE3)
3. Further executable negative tests once more dynamic failure modes are modelled
4. Machine-readable verification report artifact in CI

## License

To be determined by the author.
