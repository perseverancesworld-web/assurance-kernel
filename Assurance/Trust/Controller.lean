namespace Assurance.Trust

inductive TrustState where
  | trusted | degraded | quarantined | recovering | revoked
deriving DecidableEq, Repr

inductive TrustEvidence where
  | clean | numericalDrift | coherenceDrop | provenanceFailure
  | invariantViolation | signingCompromise | recoveryProofValid
  | unrecoverableCorruption
deriving DecidableEq, Repr

def evolve (s : TrustState) (e : TrustEvidence) : TrustState :=
  match s with
  | .revoked => .revoked
  | .quarantined =>
      match e with
      | .recoveryProofValid => .recovering
      | .signingCompromise | .unrecoverableCorruption => .revoked
      | _ => .quarantined
  | .recovering =>
      match e with
      | .clean => .trusted
      | .recoveryProofValid => .recovering
      | .signingCompromise | .unrecoverableCorruption => .revoked
      | _ => .quarantined
  | .trusted =>
      match e with
      | .clean => .trusted
      | .numericalDrift | .coherenceDrop => .degraded
      | .provenanceFailure | .invariantViolation => .quarantined
      | .signingCompromise | .unrecoverableCorruption => .revoked
      | .recoveryProofValid => .trusted
  | .degraded =>
      match e with
      | .clean => .trusted
      | .numericalDrift | .coherenceDrop => .degraded
      | .provenanceFailure | .invariantViolation => .quarantined
      | .signingCompromise | .unrecoverableCorruption => .revoked
      | .recoveryProofValid => .degraded

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

end Assurance.Trust
