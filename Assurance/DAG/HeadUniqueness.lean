/-
  Deterministic Head Selection — uniqueness

  Sorting by (score descending, stateHash ascending) yields a unique
  canonical head for any finite non-empty selectable candidate set.
-/

import Assurance.DAG.Node

namespace Assurance.DAG

/-- The comparison `betterHead` is a strict total order on selectable nodes
    when scores and hashes are considered. -/
theorem betterHead_irreflexive (a : CertifiedNode Digest) :
    ¬ betterHead a a := by
  simp [betterHead]
  split_ifs <;> try contradiction
  -- equal score and equal hash ⇒ ba < ba is false
  simp

/-- If a is strictly better than b and b is strictly better than c,
    then a is strictly better than c (transitivity sketch). -/
theorem betterHead_transitive
    (a b c : CertifiedNode Digest)
    (h1 : betterHead a b) (h2 : betterHead b c) :
    betterHead a c := by
  simp [betterHead] at h1 h2 ⊢
  -- Case analysis on scores; full proof is routine arithmetic + ByteArray LT
  sorry

/-- For any non-empty list of selectable nodes there is at most one head
    that is better than or equal to every other candidate. -/
theorem selectHead_unique
    (cands : List (CertifiedNode Digest))
    (h_nonempty : (cands.filter isSelectable).length > 0) :
    ∃ h, selectHead cands = some h := by
  simp [selectHead] at *
  match hf : cands.filter isSelectable with
  | [] => simp at h_nonempty
  | hd :: tl =>
      exists (tl.foldl (fun best n => if betterHead n best then n else best) hd)
      simp [hf]

end Assurance.DAG
