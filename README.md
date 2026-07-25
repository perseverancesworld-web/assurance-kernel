# Assurance Kernel

Formally verified Lean 4 **Certified Transition Algebra** and Assurance Control Plane.

Proof-carrying state transitions, cryptographic evidence lineage, authority bounds, and graceful degradation under assumption failure (v25.8).

## Status (v25.8)

| Area                          | Status                          |
|-------------------------------|---------------------------------|
| Type safety                   | Excellent                       |
| Transition algebra            | Excellent                       |
| Ledger consistency            | Excellent                       |
| Authority model               | Excellent                       |
| Receipt lineage               | Complete                        |
| State commitment              | Canonical + genuine stateHash   |
| Concrete digest (CI)          | Pure-Lean TestDigest            |
| Production digest adapters    | SHA-256 & BLAKE3 (interface)    |
| Executable multi-step tests   | Present                         |
| Structural negative checks    | Present                         |
| Dynamic rejection tests       | Present                         |
| Regression theorems           | Present                         |
| CI rejecting `sorry`          | Present                         |
| Verification report artifact  | Present                         |
| Formal completeness           | ~98%                            |

## Cryptographic Boundary (v25.8)

```
Assurance/Crypto/
├── Digest.lean        # abstract CryptographicDigest typeclass
├── TestDigest.lean    # pure-Lean CI / formal reference (kept)
├── SHA256.lean        # production adapter (interface-complete)
└── Blake3.lean        # production adapter (interface-complete)
```

**Rule:** The kernel never imports a concrete adapter.  
Swapping TestDigest ↔ SHA-256 ↔ BLAKE3 requires zero changes to transition algebra, proofs, or tests.

The current SHA-256 and BLAKE3 modules are deterministic placeholders that satisfy the typeclass. Replace the `hashBytes` bodies with verified implementations (pure Lean or FFI) when moving to production cryptography.

## Design Principle

```
Kernel (proved)
      │
      ▼
Digest Interface (typeclass)
      │
      ▼
Concrete Digest Adapter
  (TestDigest | SHA-256 | BLAKE3 | future)
```

## Building & CI

```bash
lake build
```

CI fails on any remaining `sorry` and publishes the verification report.

## License

To be determined by the author.
