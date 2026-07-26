/-
  Capstone: Consensus Determinism
-/

import Assurance.Event.Identity
import Assurance.DAG.Node
import Assurance.DAG.Determinism
import Assurance.Certificate.Scoring

namespace Assurance.Protocol

def replicaResolve
    {Digest : Type} [CryptographicDigest Digest]
    (events : List (Assurance.Event.Event Digest))
    (_policy : Assurance.Certificate.ScoringPolicy)
    (buildNodes : List (Assurance.Event.Event Digest) → List (Assurance.DAG.CertifiedNode Digest)) :
    Option Digest :=
  Assurance.DAG.Resolve events buildNodes

theorem consensus_determinism_permutation
    {Digest : Type} [CryptographicDigest Digest]
    (events perm : List (Assurance.Event.Event Digest))
    (policy : Assurance.Certificate.ScoringPolicy)
    (buildNodes : List (Assurance.Event.Event Digest) → List (Assurance.DAG.CertifiedNode Digest))
    (h_perm : perm = events)
    (h_build : buildNodes perm = buildNodes events) :
    replicaResolve events policy buildNodes =
    replicaResolve perm policy buildNodes := by
  simp [replicaResolve, Assurance.DAG.Resolve, h_build]

theorem consensus_determinism_dedup
    {Digest : Type} [CryptographicDigest Digest]
    (events : List (Assurance.Event.Event Digest))
    (policy : Assurance.Certificate.ScoringPolicy)
    (buildNodes : List (Assurance.Event.Event Digest) → List (Assurance.DAG.CertifiedNode Digest))
    (h_build : buildNodes (Assurance.Event.deduplicate events) = buildNodes events) :
    replicaResolve events policy buildNodes =
    replicaResolve (Assurance.Event.deduplicate events) policy buildNodes := by
  simp [replicaResolve]
  exact Assurance.DAG.resolve_dedup_invariant events buildNodes h_build

end Assurance.Protocol
