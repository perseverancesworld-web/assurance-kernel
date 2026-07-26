# Assurance Kernel

Formally verified Lean 4 foundation for **QUANTAURA-Core**:
Certified Transition Algebra + Trust Controller + Invariant Gates +
Certified DAG + Deterministic Head Selection.

## Status (v26.0)

| Layer                             | Status                          |
|-----------------------------------|---------------------------------|
| Certified state model             | Complete                        |
| Transition algebra                | Complete                        |
| Receipt lineage                   | Complete                        |
| Trust Controller                  | Formalized                      |
| Invariant gates                   | Formalized (abstract physics)   |
| Certified DAG + head selection    | Formalized                      |
| Permutation Invariance Contract   | Stated + partial proof          |
| Protocol stack                    | End-to-end skeleton             |
| Concrete digest (CI)              | TestDigest                      |
| Production digest adapters        | SHA-256 / BLAKE3 (interface)    |
| CI zero-sorry + verification report | Present                       |

## Architecture Stack (formalized)

```
Agent Intent
     ↓
Authorization & Provenance   (Trust Controller)
     ↓
Canonical Serialization
     ↓
Invariant Verification       (Gates)
     ↓
Certificate Generation
     ↓
Certified DAG Placement
     ↓
Deterministic Head Selection (score + hash tie-break)
     ↓
Replay / Convergence
```

## Core Axioms (enforced)

1. **The Intelligence Does Not Own Its History** — ledger is sole authority over the past.
2. **Capability ≠ Permission** — mathematical validity does not grant operational authority.
3. **Time Is Not Truth** — head selection is independent of network arrival order.

## Module Layout

```
Assurance/
├── Models/          # Core state, actions, transition algebra
├── Crypto/          # Digest interface + adapters
├── Ledger/
├── Proofs/
├── Execution/
├── Trust/           # Trust Controller state machine
├── Invariants/      # Provenance / Hermiticity / Spectral / Coherence gates
├── DAG/             # Node lifecycle + head selection + permutation invariance
├── Protocol/        # End-to-end stack
└── Tests/
```

## Building

```bash
lake build
```

## License

To be determined by the author.
