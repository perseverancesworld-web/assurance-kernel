# Assurance Kernel

Formally verified Lean 4 **Certified Transition Algebra** and Assurance Control Plane.

Proof-carrying state transitions, cryptographic evidence lineage, authority bounds, and graceful degradation under assumption failure (v25.7.7).

## Status (v25.7.7)

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
| Dynamic rejection tests       | Present                         |
| Regression theorems           | Present                         |
| CI rejecting `sorry`          | Present                         |
| Verification report artifact  | Present (expanded)              |
| Formal completeness           | ~98%                            |

## Dynamic Rejection Tests (v25.7.7)

`Assurance/Tests/Rejection.lean` records the following as theorems:

**Receipt integrity**
- Parent-hash mismatch → cannot form `ReceiptChain`
- Sequence gap → cannot form `ReceiptChain`
- Timestamp regression → cannot form `ReceiptChain`

**Emergency authority**
- Expired certificate → cannot form `ValidSignatureProof`
- Revoked certificate → cannot form `ValidSignatureProof`
- Insufficient quorum → cannot form `ValidSignatureProof`

**Serialization**
- Determinism (`serialize(s) = serialize(s)`)

## Verification Report

Every successful CI run produces and uploads `assurance-verification-report.txt` containing the full status of proofs, executable tests, and dynamic rejection tests.

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

1. ✅ Dynamic rejection tests
2. Optional production adapters (SHA-256 / BLAKE3)
3. Further executable negative tests if additional dynamic modes are modelled

## License

To be determined by the author.
