namespace Assurance.Trust

inductive TrustState where
  | trusted | degraded | quarantined | recovering | revoked
deriving DecidableEq, Repr

inductive TrustEvidence where
  | clean | numericalDrift | coherenceDrop | provenanceFailure
  | invariantViolation | signingCompromise | recoveryProofValid
  | unrecoverableCorruption
deriving DecidableEq, Repr

def evolve : TrustState → TrustEvidence → TrustState
  | .trusted, .clean => .trusted
  | .trusted, .numericalDrift => .degraded
  | .trusted, .coherenceDrop => .degraded
  | .trusted, .provenanceFailure => .quarantined
  | .trusted, .invariantViolation => .quarantined
  | .trusted, .signingCompromise => .revoked
  | .trusted, .unrecoverableCorruption => .revoked
  | .degraded, .clean => .trusted
  | .degraded, .numericalDrift => .degraded
  | .degraded, .coherenceDrop => .degraded
  | .degraded, .provenanceFailure => .quarantined
  | .degraded, .invariantViolation => .quarantined
  | .degraded, .signingCompromise => .revoked
  | .degraded, .unrecoverableCorruption => .revoked
  | .quarantined, .recoveryProofValid => .recovering
  | .quarantined, .signingCompromise => .revoked
  | .quarantined, .unrecoverableCorruption => .revoked
  | .quarantined, _ => .quarantined
  | .recovering, .clean => .trusted
  | .recovering, .recoveryProofValid => .recovering
  | .recovering, .signingCompromise => .revoked
  | .recovering, .unrecoverableCorruption => .revoked
  | .recovering, _ => .quarantined
  | .revoked, _ => .revoked

def mayPropose : TrustState → Bool
  | .trusted | .degraded | .recovering => true
  | .quarantined | .revoked => false

def mayMutate : TrustState → Bool
  | .trusted | .degraded => true
  | _ => false

theorem revoked_absorbing (e : TrustEvidence) :
    evolve .revoked e = .revoked := by
  cases e <;> rfl

theorem no_propose_revoked : mayPropose .revoked = false := rfl

theorem no_propose_quarantined : mayPropose .quarantined = false := rfl

theorem no_mutate_quarantined : mayMutate .quarantined = false := rfl

theorem no_mutate_revoked : mayMutate .revoked = false := rfl

theorem recovery_needs_proof (e : TrustEvidence)
    (h : evolve .quarantined e = .recovering) :
    e = .recoveryProofValid := by
  cases e <;> simp [evolve] at h <;> try rfl

end Assurance.Trust
