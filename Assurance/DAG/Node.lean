import Assurance.Models.DegradationRules
import Assurance.Invariants.Gates
import Assurance.Trust.Controller
import Assurance.Certificate.Scoring
import Assurance.Crypto.Digest

open Assurance.Crypto

namespace Assurance.DAG

inductive NodeStatus
  | proposed | verified | accepted | superseded | quarantined | rejected
deriving DecidableEq, Repr

structure CertifiedNode (Digest : Type) [CryptographicDigest Digest] where
  id : Digest
  parentId : Option Digest
  stateHash : Digest
  certificate : Assurance.Certificate.SignedCertificate Digest
  score : Nat
  status : NodeStatus
  trustAtPlacement : Assurance.Trust.TrustState
  invariants : Assurance.Invariants.InvariantVerdict
  logicalTime : Nat

def isSelectable (n : CertifiedNode Digest) : Bool :=
  n.status = .verified || n.status = .accepted

def betterHead (a b : CertifiedNode Digest) : Bool :=
  if a.score > b.score then true
  else if a.score < b.score then false
  else bytesLt (toBytes a.stateHash) (toBytes b.stateHash)

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
