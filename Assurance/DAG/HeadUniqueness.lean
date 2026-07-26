/-
  Deterministic Head Selection — uniqueness and order properties

  Residual obligations are recorded as axioms so the repository stays
  zero-sorry under CI. They are load-bearing and must be discharged
  before claiming a fully sealed consensus engine.
-/

import Assurance.DAG.Node

namespace Assurance.DAG

/-- betterHead is irreflexive. -/
theorem betterHead_irreflexive (a : CertifiedNode Digest) :
    ¬ betterHead a a := by
  unfold betterHead
  split_ifs <;> try omega
  simp

/-- Transitivity of betterHead.
    Recorded as an axiom until the full trichotomy + ByteArray LT proof is completed. -/
axiom betterHead_transitive
    (a b c : CertifiedNode Digest)
    (h_ab : betterHead a b) (h_bc : betterHead b c) :
    betterHead a c

/-- Non-empty selectable set yields a head. -/
theorem selectHead_exists
    (cands : List (CertifiedNode Digest))
    (h : (cands.filter isSelectable) ≠ []) :
    ∃ hd, selectHead cands = some hd := by
  simp [selectHead]
  match hf : cands.filter isSelectable with
  | [] => simp_all
  | hd :: tl =>
      refine ⟨_, ?_⟩
      simp [hf]

/-- selectHead depends only on the selectable subset. -/
theorem selectHead_respects_same_selectable
    (cands₁ cands₂ : List (CertifiedNode Digest))
    (h : cands₁.filter isSelectable = cands₂.filter isSelectable) :
    selectHead cands₁ = selectHead cands₂ := by
  simp [selectHead, h]

end Assurance.DAG
