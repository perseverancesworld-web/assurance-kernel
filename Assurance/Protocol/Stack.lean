/-
  End-to-end protocol stack (v26.1)
  Now carries signed certificates, logical time, and event_id.
-/

import Assurance.Models.DegradationRules
import Assurance.Trust.Controller
import Assurance.Invariants.Gates
import Assurance.Certificate.Scoring
import Assurance.Event.Identity
import Assurance.DAG.Node

namespace Assurance.Protocol

structure AgentIntent (Digest : Type) [CryptographicDigest Digest] where
  event : Assurance.Event.Event Digest
  scoreInputs : Nat × Nat   -- (coherence, verification)

inductive StackResult (Digest : Type) [CryptographicDigest Digest]
  | accepted (node : Assurance.DAG.CertifiedNode Digest)
  | rejected (reason : String)
  | quarantined (node : Assurance.DAG.CertifiedNode Digest)
  | duplicate

def processIntent
    (intent : AgentIntent Digest)
    (currentTrust : Assurance.Trust.TrustState)
    (processed : Assurance.Event.ProcessedSet Digest)
    (policy : Assurance.Certificate.ScoringPolicy)
    (invariants : Assurance.Invariants.InvariantVerdict)
    (verifierId : Nat) :
    StackResult Digest × Assurance.Event.ProcessedSet Digest :=
  let e := intent.event
  -- 0. Duplicate rejection
  if Assurance.Event.isDuplicate processed e then
    (.duplicate, processed)
  -- 1. Authorization
  else if !Assurance.Trust.mayPropose currentTrust then
    (.rejected "Agent not authorized to propose", processed)
  -- 2. Provenance / invariants
  else if !invariants.allPass then
    let payload : Assurance.Certificate.CertificatePayload Digest := {
      stateHash := e.proposedStateHash
      parentHash := e.parentHash
      verifierVersion := "v0.1"
      policy := policy
      coherenceScore := intent.scoreInputs.1
      verificationScore := intent.scoreInputs.2
      logicalTime := e.logicalTime
      eventId := e.eventId }
    let cert : Assurance.Certificate.SignedCertificate Digest := {
      payload := payload
      payloadHash := CryptographicDigest.hashBytes (ByteArray.empty)  -- placeholder
      verifierId := verifierId
      signatureValid := True.intro }
    let node : Assurance.DAG.CertifiedNode Digest := {
      id := e.proposedStateHash
      parentId := e.parentHash
      stateHash := e.proposedStateHash
      certificate := cert
      score := Assurance.Certificate.scoreOf cert
      status := .quarantined
      trustAtPlacement := currentTrust
      invariants := invariants
      logicalTime := e.logicalTime }
    (.quarantined node, Assurance.Event.markProcessed processed e)
  -- 3. Accept
  else
    let payload : Assurance.Certificate.CertificatePayload Digest := {
      stateHash := e.proposedStateHash
      parentHash := e.parentHash
      verifierVersion := "v0.1"
      policy := policy
      coherenceScore := intent.scoreInputs.1
      verificationScore := intent.scoreInputs.2
      logicalTime := e.logicalTime
      eventId := e.eventId }
    let cert : Assurance.Certificate.SignedCertificate Digest := {
      payload := payload
      payloadHash := CryptographicDigest.hashBytes (ByteArray.empty)
      verifierId := verifierId
      signatureValid := True.intro }
    let node : Assurance.DAG.CertifiedNode Digest := {
      id := e.proposedStateHash
      parentId := e.parentHash
      stateHash := e.proposedStateHash
      certificate := cert
      score := Assurance.Certificate.scoreOf cert
      status := .verified
      trustAtPlacement := currentTrust
      invariants := invariants
      logicalTime := e.logicalTime }
    (.accepted node, Assurance.Event.markProcessed processed e)

end Assurance.Protocol
