/-
  Trust Controller — operational permission machine
  Separates capability (mathematical validity) from permission (operational state).

  States: TRUSTED | DEGRADED | QUARANTINED | RECOVERING | REVOKED
-/

import Assurance.Models.DegradationRules

namespace Assurance.Trust

inductive TrustState
  | trusted
  | degraded
  | quarantined
  | recovering
  | revoked
deriving DecidableEq, Repr

/-- Evidence that may trigger a trust transition. -/
inductive TrustEvidence
  | clean
  | numericalDrift
  | coherenceDrop
  | provenanceFailure
  | invariantViolation
  | signingCompromise
  | recoveryProofValid
  | unrecoverableCorruption
deriving DecidableEq, Repr

/-- Deterministic trust evolution: S_{t+1} = T(S_t, E_t). -/
def evolve (s : TrustState) (e : TrustEvidence) : TrustState :=
  match s, e with
  | .trusted, .clean                 => .trusted
  | .trusted, .numericalDrift        => .degraded
  | .trusted, .coherenceDrop         => .degraded
  | .trusted, .provenanceFailure     => .quarantined
  | .trusted, .invariantViolation    => .quarantined
  | .trusted, .signingCompromise     => .revoked
  | .trusted, .unrecoverableCorruption => .revoked
  | .degraded, .clean                => .trusted
  | .degraded, .numericalDrift       => .degraded
  | .degraded, .coherenceDrop        => .degraded
  | .degraded, .provenanceFailure    => .quarantined
  | .degraded, .invariantViolation   => .quarantined
  | .degraded, .signingCompromise    => .revoked
  | .degraded, .unrecoverableCorruption => .revoked
  | .quarantined, .recoveryProofValid => .recovering
  | .quarantined, .signingCompromise => .revoked
  | .quarantined, .unrecoverableCorruption => .revoked
  | .quarantined, _                  => .quarantined
  | .recovering, .clean              => .trusted
  | .recovering, .recoveryProofValid => .recovering
  | .recovering, .signingCompromise  => .revoked
  | .recovering, .unrecoverableCorruption => .revoked
  | .recovering, _                   => .quarantined
  | .revoked, _                      => .revoked

/-- Operational privileges granted by each trust state. -/
def mayPropose (s : TrustState) : Bool :=
  match s with
  | .trusted | .degraded | .recovering => true
  | .quarantined | .revoked => false

def mayMutate (s : TrustState) : Bool :=
  match s with
  | .trusted | .degraded => true
  | _ => false

def isTerminal (s : TrustState) : Bool :=
  s = .revoked

/-- Once revoked, always revoked. -/
theorem revoked_is_absorbing (e : TrustEvidence) :
    evolve .revoked e = .revoked := by
  cases e <;> rfl

/-- Quarantined and revoked entities cannot mutate state. -/
theorem no_mutate_when_quarantined_or_revoked (s : TrustState)
    (h : s = .quarantined ∨ s = .revoked) :
    mayMutate s = false := by
  cases h with
  | inl h => rw [h]; rfl
  | inr h => rw [h]; rfl

end Assurance.Trust
