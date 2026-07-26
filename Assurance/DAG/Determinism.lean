/-
  State-machine determinism under duplicate delivery.

  Resolve(Deduplicate(E)) = Resolve(E)
  (when duplicate events share the same event_id)
-/

import Assurance.Event.Identity
import Assurance.DAG.Node

namespace Assurance.DAG

/-- Abstract resolution of a list of events into a canonical head hash. -/
def Resolve {Digest : Type} [CryptographicDigest Digest]
    (events : List (Assurance.Event.Event Digest))
    (buildNodes : List (Assurance.Event.Event Digest) → List (CertifiedNode Digest)) :
    Option Digest :=
  let nodes := buildNodes events
  match selectHead nodes with
  | none => none
  | some h => some h.stateHash

/-- The required contract:
    after deduplication, resolution yields the same head. -/
theorem resolve_dedup_invariant
    {Digest : Type} [CryptographicDigest Digest]
    (events : List (Assurance.Event.Event Digest))
    (buildNodes : List (Assurance.Event.Event Digest) → List (CertifiedNode Digest))
    (h_build_respects_dedup :
      buildNodes (Assurance.Event.deduplicate events) =
      buildNodes events) :
    Resolve (Assurance.Event.deduplicate events) buildNodes =
    Resolve events buildNodes := by
  simp [Resolve, h_build_respects_dedup]

end Assurance.DAG
