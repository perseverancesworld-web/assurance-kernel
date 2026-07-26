import Assurance.Crypto.Digest
import Assurance.Trust.Controller
import Assurance.Invariants.Gates
import Assurance.Event.Identity
import Assurance.DAG.Node
import Assurance.Certificate.Scoring

open Assurance.Crypto

namespace Assurance.Protocol

structure AgentIntent (Digest : Type) [DecidableEq Digest] where
  event : Assurance.Event.Event Digest
  coherence : Nat
  verification : Nat

inductive StackResult (Digest : Type) [DecidableEq Digest] [CryptographicDigest Digest] where
  | accepted (node : Assurance.DAG.CertifiedNode Digest)
  | rejected (reason : String)
  | duplicate

def processIntent
    {Digest : Type} [DecidableEq Digest] [CryptographicDigest Digest]
    (intent : AgentIntent Digest)
    (trust : Assurance.Trust.TrustState)
    (seen : List Digest)
    (policy : Assurance.Certificate.ScoringPolicy)
    (verdict : Assurance.Invariants.InvariantVerdict) :
    StackResult Digest × List Digest :=
  let e := intent.event
  if Assurance.Event.isDuplicate seen e then
    (.duplicate, seen)
  else if !(Assurance.Trust.mayPropose trust) then
    (.rejected "not authorized", seen)
  else if !(verdict.allPass) then
    (.rejected "invariant failure", Assurance.Event.markProcessed seen e)
  else
    let node : Assurance.DAG.CertifiedNode Digest := {
      id := e.proposedStateHash
      parentId := none
      stateHash := e.proposedStateHash
      score := Assurance.Certificate.scoreOf policy intent.coherence intent.verification
      status := .verified
      trustAtPlacement := trust
      logicalTime := e.logicalTime }
    (.accepted node, Assurance.Event.markProcessed seen e)

end Assurance.Protocol
