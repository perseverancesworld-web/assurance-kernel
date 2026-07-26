# Assurance Kernel

Formally verified Lean 4 foundation for **QUANTAURA-Core**.

Certified Transition Algebra · Trust Controller · Invariant Gates ·
Signed Scoring Certificates · Event Identity · Deterministic DAG Head Selection ·
Permutation & Duplicate-Delivery Invariance.

## Status (v26.1)

| Layer | Status |
|-------|--------|
| Certified state model | Complete |
| Transition algebra | Complete |
| Trust Controller | Complete |
| Invariant gates | Formalized |
| Signed scoring certificates | Complete |
| Logical vs observed time | Separated |
| Event identity + deduplication | Complete |
| Deterministic head selection | Complete |
| Permutation invariance | Stated |
| Duplicate-delivery determinism | Theorem target |
| Concrete digest (CI) | TestDigest |
| Production adapters | SHA-256 / BLAKE3 interface |

## Core Guarantees

```
Events + HistoricalCertificates → Canonical Head
```

- No network-order bias (score + lex hash total order)
- No silent policy drift (versioned certificates)
- No duplicate-induced divergence (`Resolve(Deduplicate(E)) = Resolve(E)`)
- Capability ≠ Permission (Trust Controller)
- History is owned by the ledger, not by agents

## Building

```bash
lake build
```

## License

To be determined by the author.
