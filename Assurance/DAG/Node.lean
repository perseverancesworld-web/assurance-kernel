import Assurance.Crypto.Digest
import Assurance.Trust.Controller
import Assurance.Invariants.Gates
import Assurance.Certificate.Scoring

open Assurance.Crypto

namespace Assurance.DAG

inductive NodeStatus where
  | proposed | verified | accepted | superseded | quarantined | rejected
deriving DecidableEq, Repr

structure CertifiedNode (Digest : Type) [DecidableEq Digest] [CryptographicDigest Digest] where
  id : Digest
  parentId : Option Digest
  stateHash : Digest
  score : Nat
  status : NodeStatus
  trustAtPlacement : Assurance.Trust.TrustState
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

theorem betterHead_irrefl (a : CertifiedNode Digest) :
    betterHead a a = false := by
  simp [betterHead]
  split_ifs <;> try rfl
  -- equal score → bytesLt a a should be false
  simp [bytesLt]

end Assurance.DAG
