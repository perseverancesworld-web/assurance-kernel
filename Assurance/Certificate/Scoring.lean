namespace Assurance.Certificate

structure ScoringPolicy where
  scoringVersion : String
  weightCoherence : Nat
  weightVerification : Nat
deriving DecidableEq, Repr

def scoreOf (policy : ScoringPolicy) (coherence verification : Nat) : Nat :=
  policy.weightCoherence * coherence + policy.weightVerification * verification

theorem score_deterministic (p : ScoringPolicy) (c v : Nat) :
    scoreOf p c v = scoreOf p c v := rfl

theorem policy_neq_of_weight_change (p1 p2 : ScoringPolicy)
    (h : p1.weightCoherence ≠ p2.weightCoherence) :
    p1 ≠ p2 := by
  intro heq; cases heq; exact h rfl

end Assurance.Certificate
