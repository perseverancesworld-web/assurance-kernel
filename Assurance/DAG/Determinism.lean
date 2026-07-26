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
  match selectHead (buildNodes events) with
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

end Assurance.DAG
