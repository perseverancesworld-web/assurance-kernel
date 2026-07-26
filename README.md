# Assurance Kernel

Formally verified Lean 4 foundation for **QUANTAURA-Core** (v26.3).

## Green CI core (no Mathlib)

| Module | Role |
|--------|------|
| Crypto | Digest interface + TestDigest |
| Models | SystemState, authority bounds, failed-state lock |
| Trust | Trust controller + safety theorems |
| Invariants | Gate results + allPass |
| Certificate | Versioned scoring policy |
| Event | event_id + dedup |
| DAG | CertifiedNode + deterministic head selection |
| Protocol | End-to-end intent pipeline |

## Build

```bash
lake build
```

Toolchain: `leanprover/lean4:v4.12.0`

## Next

- Discharge residual ordering lemmas
- Optional Mathlib for richer list/Finset proofs
- Lean ↔ Python refinement
- Concrete physics gates
