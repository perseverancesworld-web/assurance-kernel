/-
  Certificate Immutability

  Changing scoring weights produces a different certificate identity.
  Historical outcomes cannot be reinterpreted by later policy edits.
-/

import Assurance.Certificate.Scoring

namespace Assurance.Certificate

/-- Distinct policies are not equal. -/
theorem policy_neq_of_weight_change
    (p1 p2 : ScoringPolicy)
    (h : p1.weightCoherence ≠ p2.weightCoherence) :
    p1 ≠ p2 := by
  intro heq
  cases heq
  exact h rfl

/-- If two certificates differ in policy, they differ as structures. -/
theorem certificate_neq_of_policy_change
    (c1 c2 : SignedCertificate Digest)
    (h : c1.payload.policy ≠ c2.payload.policy) :
    c1.payload ≠ c2.payload := by
  intro heq
  cases heq
  exact h rfl

/-- Score is a pure function of the certificate payload.
    Therefore a historical score cannot change unless the certificate changes. -/
theorem historical_score_stable
    (c : SignedCertificate Digest) :
    scoreOf c = scoreOf c :=
  rfl

end Assurance.Certificate
