/-
  Immutable scoring certificates

  LedgerState = f(Events, HistoricalCertificates)
  not f(Events, CurrentCode).

  A certificate records the exact policy and inputs that produced a score
  and is itself cryptographic evidence (hash + signature obligation).
-/

import Assurance.Models.DegradationRules

namespace Assurance.Certificate

/-- Versioned scoring policy. Once emitted, it is immutable history. -/
structure ScoringPolicy where
  scoringVersion : String
  weightCoherence : Nat      -- fixed-point or scaled integer for determinism
  weightVerification : Nat
  deriving DecidableEq, Repr

/-- Canonical certificate payload (everything that must be hashed). -/
structure CertificatePayload (Digest : Type) [CryptographicDigest Digest] where
  stateHash : Digest
  parentHash : Option Digest
  verifierVersion : String
  policy : ScoringPolicy
  coherenceScore : Nat
  verificationScore : Nat
  logicalTime : Nat          -- consensus time, not wall-clock
  eventId : Digest           -- first-class event identity
  deriving Repr

/-- A fully formed certificate includes the payload hash and a signature obligation. -/
structure SignedCertificate (Digest : Type) [CryptographicDigest Digest] where
  payload : CertificatePayload Digest
  payloadHash : Digest
  verifierId : Nat
  /-- Signature obligation: in a concrete model this is a real signature.
      Here we record that a valid signature must exist. -/
  signatureValid : True

/-- Deterministic score derived solely from the certificate. -/
def scoreOf (c : SignedCertificate Digest) : Nat :=
  c.payload.policy.weightCoherence * c.payload.coherenceScore +
  c.payload.policy.weightVerification * c.payload.verificationScore

/-- Two certificates with identical payloads must produce identical scores. -/
theorem score_deterministic
    (c1 c2 : SignedCertificate Digest)
    (h : c1.payload = c2.payload) :
    scoreOf c1 = scoreOf c2 := by
  simp [scoreOf, h]

end Assurance.Certificate
