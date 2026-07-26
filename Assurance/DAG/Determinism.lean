/-
  State-machine determinism under duplicate delivery and permutation.
-/

import Assurance.Event.Identity
import Assurance.DAG.Node
import Assurance.DAG.HeadUniqueness

namespace Assurance.DAG

def Resolve {Digest : Type} [CryptographicDigest Digest]
    (events : List (Assurance.Event.Event Digest))
    (buildNodes : List (Assurance.Event.Event Digest) → List (CertifiedNode Digest)) :
    Option Digest :=
  let nodes := buildNodes events
  match selectHead nodes with
  | none => none
  | some h => some h.stateHash

theorem resolve_dedup_invariant
    {Digest : Type} [CryptographicDigest Digest]
    (events : List (Assurance.Event.Event Digest))
    (buildNodes : List (Assurance.Event.Event Digest) → List (CertifiedNode Digest))
    (h_build : buildNodes (Assurance.Event.deduplicate events) = buildNodes events) :
    Resolve (Assurance.Event.deduplicate events) buildNodes =
    Resolve events buildNodes := by
  simp [Resolve, h_build]

/-- If two candidate lists contain exactly the same selectable nodes
    (as a multiset), selectHead yields the same result.
    This is the key helper for permutation invariance. -/
theorem selectHead_respects_same_selectable
    (cands₁ cands₂ : List (CertifiedNode Digest))
    (h : cands₁.filter isSelectable = cands₂.filter isSelectable) :
    selectHead cands₁ = selectHead cands₂ := by
  simp [selectHead, h]

end Assurance.DAG
