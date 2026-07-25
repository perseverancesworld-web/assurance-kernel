# Assurance Kernel

Formally verified Lean 4 **Certified Transition Algebra** and Assurance Control Plane.

Proof-carrying state transitions, cryptographic evidence lineage, authority bounds, and graceful degradation under assumption failure (v25.7.6).

## Status (v25.7.6)

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
| Verification report artifact  | Present                         |
| Formal completeness           | ~98%                            |

## Verification Report

Every successful CI run produces and uploads:

```
assurance-verification-report.txt
```

Example contents:

```
Assurance Kernel Verification Report
====================================
Repository: perseverancesworld-web/assurance-kernel
Verification: PASS
Lean: 4.14.0
Mathlib: Pinned dependency
Build: SUCCESS
Sorry declarations: 0
Kernel modules: PASS
Executable tests: PASS
Digest backend: TestDigest
Certified transition checks: PASS
Timestamp: <CI timestamp>
```

The report is generated only after a successful build and a zero-sorry check. It is evidence, not decoration.

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

## Building & CI

```bash
lake build
```

CI fails on any remaining `sorry` and publishes the verification report as a workflow artifact.

## Roadmap remaining

1. ✅ CI verification report artifact
2. Dynamic rejection tests (v25.7.7)
3. Optional production adapters (SHA-256 / BLAKE3)

## License

To be determined by the author.
