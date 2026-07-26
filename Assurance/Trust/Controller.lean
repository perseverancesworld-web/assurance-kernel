namespace Assurance.Trust

inductive TrustState
  | trusted | degraded | quarantined | recovering | revoked
deriving DecidableEq, Repr

inductive TrustEvidence
  | clean | numericalDrift | coherenceDrop | provenanceFailure
  | invariantViolation | signingCompromise | recoveryProofValid
  | unrecoverableCorruption
deriving DecidableEq, Repr

def evolve (s : TrustState) (e : TrustEvidence) : TrustState :=
  match s, e with
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
  | _, _ => s

def mayPropose : TrustState → Bool
  | .trusted | .degraded | .recovering => true
  | .quarantined | .revoked => false

def mayMutate : TrustState → Bool
  | .trusted | .degraded => true
  | _ => false

theorem revoked_is_absorbing (e : TrustEvidence) :
    evolve .revoked e = .revoked := by
  cases e <;> rfl

theorem cannot_propose_when_revoked :
    mayPropose .revoked = false := rfl

theorem cannot_mutate_when_quarantined :
    mayMutate .quarantined = false := rfl

end Assurance.Trust
