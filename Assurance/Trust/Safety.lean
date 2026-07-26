/-
  Trust-State Safety

  Privileged operations are impossible from QUARANTINED or REVOKED
  without an explicit recovery path.
-/

import Assurance.Trust.Controller

namespace Assurance.Trust

/-- Quarantined and revoked actors cannot propose. -/
theorem cannot_propose_when_quarantined (s : TrustState)
    (h : s = .quarantined) :
    mayPropose s = false := by
  rw [h]; rfl

theorem cannot_propose_when_revoked (s : TrustState)
    (h : s = .revoked) :
    mayPropose s = false := by
  rw [h]; rfl

/-- Quarantined and revoked actors cannot mutate. -/
theorem cannot_mutate_when_quarantined_or_revoked (s : TrustState)
    (h : s = .quarantined ∨ s = .revoked) :
    mayMutate s = false :=
  no_mutate_when_quarantined_or_revoked s h

/-- Revoked is a terminal sink. -/
theorem revoked_terminal (e : TrustEvidence) :
    evolve .revoked e = .revoked :=
  revoked_is_absorbing e

/-- Recovery from quarantined requires an explicit recoveryProofValid evidence. -/
theorem recovery_requires_explicit_proof (e : TrustEvidence)
    (h : evolve .quarantined e = .recovering) :
    e = .recoveryProofValid := by
  cases e <;> simp [evolve] at h <;> try contradiction
  rfl

end Assurance.Trust
