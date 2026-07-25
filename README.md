# Assurance Kernel

Formally verified Lean 4 **Certified Transition Algebra** and Assurance Control Plane.

Proof-carrying state transitions, cryptographic evidence lineage, authority bounds, and graceful degradation under assumption failure (v25.7+).

## Core Ideas

- **Structural exclusion** of illegal states via `Fin 10001` and `RecoverableState`
- **Dependent actions** that carry their own evidence (`ValidAction`)
- **ReceiptChain** with cryptographic adjacency + temporal ordering
- **CertifiedTransition** as a first-class mathematical object
- **KernelInvariant** bundle: authority safety, lineage, failure-sink protection, temporal monotonicity
- Fail-closed Assurance Control Plane philosophy (THM-GOV-001 style)

## Current Status (v25.7.2 / v25.7.3 scaffolding)

| Area                      | Status          |
|---------------------------|-----------------|
| Type safety               | Excellent       |
| Transition algebra        | Excellent       |
| Ledger consistency        | Excellent       |
| Authority model           | Excellent       |
| Receipt lineage           | Inversion lemma |
| Cryptographic commitments | Serializer WIP  |
| Concrete execution        | Digest instance needed |
| Formal completeness       | ~95-97%         |

## Path Forward

1. Complete `ReceiptChain.head_timestamp_ge` (done in scaffolding)
2. Canonical serialization for `SystemState`
3. Real `stateHash` from serialized state
4. Concrete `CryptographicDigest` instance
5. Executable regression tests

## License

To be determined by the author.
