namespace Assurance.Trust

inductive TrustState where
  | trusted
  | degraded
  | quarantined
  | recovering
  | revoked
deriving DecidableEq, Repr

inductive TrustEvidence where
  | clean
  | numericalDrift
  | provenanceFailure
  | signingCompromise
  | recoveryProofValid
deriving DecidableEq, Repr

def evolve : TrustState → TrustEvidence → TrustState
  | .trusted, .clean => .trusted
  | .trusted, .numericalDrift => .degraded
  | .trusted, .provenanceFailure => .quarantined
  | .trusted, .signingCompromise => .revoked
  | .degraded, .clean => .trusted
  | .degraded, .provenanceFailure => .quarantined
  | .degraded, .signingCompromise => .revoked
  | .quarantined, .recoveryProofValid => .recovering
  | .quarantined, .signingCompromise => .revoked
  | .recovering, .clean => .trusted
  | .recovering, .signingCompromise => .revoked
  | .revoked, _ => .revoked
  | s, _ => s

def mayPropose : TrustState → Bool
  | .trusted | .degraded | .recovering => true
  | .quarantined | .revoked => false

theorem revoked_absorbing (e : TrustEvidence) :
    evolve .revoked e = .revoked := by
  cases e <;> rfl

theorem no_propose_revoked : mayPropose .revoked = false := rfl

end Assurance.Trust
