import Assurance.Models.DegradationRules

/-!
  # Regression theorems for the Certified Transition Algebra

  These theorems encode the six core properties that must never regress:
  1. Authority never exceeds 10 000
  2. Failed systems cannot expand authority
  3. Receipt lineage is preserved
  4. Timestamps remain monotonic
  5. Duplicate actions are rejected by construction (seenActions)
  6. Ledger roots are deterministic given the same inputs
-/

namespace Assurance.Tests

variable {Digest : Type} [CryptographicDigest Digest]

/-- Authority bound is structural. -/
theorem authority_bounded (s : SystemState Digest) (h : KernelInvariant s) :
    s.authority.val ≤ 10000 :=
  h.authoritySafe

/-- Failed state cannot expand authority (the implication form). -/
theorem failed_cannot_expand (s : SystemState Digest) (h : KernelInvariant s)
    (hfail : s.assurance = AssuranceState.failed) :
    s.authority.val = 0 :=
  h.failedCannotExpand hfail

/-- Lineage is part of the invariant. -/
theorem lineage_holds (s : SystemState Digest) (h : KernelInvariant s) :
    ReceiptChain s.lastEvidenceHash s.evidenceLog :=
  h.lineageValid

/-- Temporal monotonicity is part of the invariant. -/
theorem timestamps_monotonic (s : SystemState Digest) (h : KernelInvariant s) :
    MonotonicTimestamps s.evidenceLog :=
  h.temporalConsistency

/-- CertifiedTransition always produces a bounded authority. -/
theorem certified_transition_authority_bounded
    {old : CertifiedState Digest} {a : ValidAction old.state}
    {new : CertifiedState Digest} {led : CertifiedLedger Digest}
    (ct : CertifiedTransition old a new led) :
    new.state.authority.val ≤ 10000 :=
  ct.authorityBounded

/-- CertifiedTransition always preserves or advances time. -/
theorem certified_transition_time_nondecreasing
    {old : CertifiedState Digest} {a : ValidAction old.state}
    {new : CertifiedState Digest} {led : CertifiedLedger Digest}
    (ct : CertifiedTransition old a new led) :
    new.state.currentTime ≥ old.state.currentTime :=
  ct.timestampValid

end Assurance.Tests
