/-
  Certified DAG node lifecycle and deterministic head selection.

  Node states: PROPOSED | VERIFIED | ACCEPTED | SUPERSEDED | QUARANTINED | REJECTED
  Head selection: highest score, then lexicographic state hash (permutation-invariant).
-/

import Assurance.Models.DegradationRules
import Assurance.Invariants.Gates
import Assurance.Trust.Controller

namespace Assurance.DAG

inductive NodeStatus
  | proposed
  | verified
  | accepted
  | superseded
  | quarantined
  | rejected
deriving DecidableEq, Repr

structure CertifiedNode (Digest : Type) [CryptographicDigest Digest] where
  id : Digest
  parentId : Option Digest
  stateHash : Digest
  score : Int
  status : NodeStatus
  trustAtPlacement : Assurance.Trust.TrustState
  invariants : Assurance.Invariants.InvariantVerdict
  timestamp : Nat

/-- Only verified or accepted nodes may become the canonical head. -/
def isSelectable (n : CertifiedNode Digest) : Bool :=
  n.status = .verified || n.status = .accepted

/-- Deterministic total order for head selection.
    Primary: higher score wins.
    Secondary: lexicographic state hash (as bytes) breaks ties.
    Network arrival order never participates. -/
def betterHead (a b : CertifiedNode Digest) : Bool :=
  if a.score > b.score then true
  else if a.score < b.score then false
  else
    -- lexicographic comparison of state hashes
    let ba := CryptographicDigest.toBytes a.stateHash
    let bb := CryptographicDigest.toBytes b.stateHash
    ba < bb   -- ByteArray has decidable LT in recent Lean; adjust if needed

/-- Select the canonical head from a list of candidate nodes.
    Returns none if no selectable candidate exists. -/
def selectHead (candidates : List (CertifiedNode Digest)) : Option (CertifiedNode Digest) :=
  let selectable := candidates.filter isSelectable
  match selectable with
  | [] => none
  | hd :: tl => some (tl.foldl (fun best n => if betterHead n best then n else best) hd)

/-- Node lifecycle transition (simplified). -/
def advanceStatus (n : CertifiedNode Digest) (event : String) : CertifiedNode Digest :=
  match n.status, event with
  | .proposed, "verify_ok"   => { n with status := .verified }
  | .proposed, "verify_fail" => { n with status := .rejected }
  | .verified, "accept"      => { n with status := .accepted }
  | .verified, "supersede"   => { n with status := .superseded }
  | .accepted, "supersede"   => { n with status := .superseded }
  | _, "quarantine"          => { n with status := .quarantined }
  | s, _                     => n   -- no change

end Assurance.DAG
