/-
  Certified DAG node lifecycle and deterministic head selection.
  Updated (v26.1) to bind signed certificates and logical time.
-/

import Assurance.Models.DegradationRules
import Assurance.Invariants.Gates
import Assurance.Trust.Controller
import Assurance.Certificate.Scoring

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
  certificate : Assurance.Certificate.SignedCertificate Digest
  score : Nat                    -- derived from certificate only
  status : NodeStatus
  trustAtPlacement : Assurance.Trust.TrustState
  invariants : Assurance.Invariants.InvariantVerdict
  logicalTime : Nat              -- consensus time (from event / certificate)
  -- observed wall-clock is intentionally absent from the node

def isSelectable (n : CertifiedNode Digest) : Bool :=
  n.status = .verified || n.status = .accepted

/-- Total order for head selection.
    Primary: higher score.
    Secondary: lexicographic state hash.
    Network arrival order never participates. -/
def betterHead (a b : CertifiedNode Digest) : Bool :=
  if a.score > b.score then true
  else if a.score < b.score then false
  else
    let ba := CryptographicDigest.toBytes a.stateHash
    let bb := CryptographicDigest.toBytes b.stateHash
    ba < bb

def selectHead (candidates : List (CertifiedNode Digest)) : Option (CertifiedNode Digest) :=
  let selectable := candidates.filter isSelectable
  match selectable with
  | [] => none
  | hd :: tl => some (tl.foldl (fun best n => if betterHead n best then n else best) hd)

def advanceStatus (n : CertifiedNode Digest) (event : String) : CertifiedNode Digest :=
  match n.status, event with
  | .proposed, "verify_ok"   => { n with status := .verified }
  | .proposed, "verify_fail" => { n with status := .rejected }
  | .verified, "accept"      => { n with status := .accepted }
  | .verified, "supersede"   => { n with status := .superseded }
  | .accepted, "supersede"   => { n with status := .superseded }
  | _, "quarantine"          => { n with status := .quarantined }
  | _, _                     => n

end Assurance.DAG
