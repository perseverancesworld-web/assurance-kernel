# Assurance Kernel

Formally verified Lean 4 **Certified Transition Algebra** and Assurance Control Plane.

Proof-carrying state transitions, cryptographic evidence lineage, authority bounds, and graceful degradation under assumption failure (v25.7.4).

## Repository Layout

```
assurance-kernel/
├── lakefile.lean
├── lean-toolchain
├── .github/workflows/lean.yml
├── Assurance/
│   ├── Models/          # Core state, actions, invariants, transition algebra
│   ├── Crypto/
│   │   ├── Digest.lean       # abstract typeclass
│   │   └── TestDigest.lean   # pure-Lean deterministic instance
│   ├── Ledger/
│   ├── Proofs/
│   ├── Execution/
│   └── Tests/
│       ├── Regression.lean
│       └── Smoke.lean         # executable end-to-end test
└── README.md
```

## Status (v25.7.4)

| Area                          | Status                          |
|-------------------------------|---------------------------------|
| Type safety                   | Excellent                       |
| Transition algebra            | Excellent                       |
| Ledger consistency            | Excellent                       |
| Authority model               | Excellent                       |
| Receipt lineage               | Complete                        |
| State commitment              | Canonical + genuine stateHash   |
| Concrete digest               | Pure-Lean TestDigest            |
| Executable smoke test         | Present                         |
| Regression theorems           | Present                         |
| CI rejecting `sorry`          | Present                         |
| Formal completeness           | ~98%                            |

## Building & CI

```bash
lake build
```

CI runs on every push to `main` and fails if any `sorry` remains.

The smoke test (`Assurance/Tests/Smoke.lean`) exercises a full genesis → ingestTelemetry path using the pure-Lean digest.

## Design Principle

```
Kernel (proved)
      │
      ▼
Digest Interface (typeclass)
      │
      ▼
Concrete Digest Adapter (TestDigest today, SHA-256/BLAKE3 tomorrow)
      │
      ▼
Runtime / Applications
```

Swapping the digest implementation must never require changes to the transition algebra or its proofs.

## Roadmap remaining

1. ✅ Pure-Lean TestDigest + smoke test
2. Optional production adapters (SHA-256 / BLAKE3)
3. Expanded executable regression suite
4. Performance / interoperability tests against external implementations

## License

To be determined by the author.
