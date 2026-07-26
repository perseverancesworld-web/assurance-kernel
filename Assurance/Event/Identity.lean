/-
  First-class event identity and duplicate-delivery rejection.
-/

import Assurance.Models.DegradationRules

namespace Assurance.Event

structure Event (Digest : Type) [CryptographicDigest Digest] where
  eventId : Digest
  agentId : Nat
  logicalTime : Nat
  observedTime : Nat
  payload : ByteArray
  parentHash : Option Digest
  proposedStateHash : Digest

def ProcessedSet (Digest : Type) [CryptographicDigest Digest] :=
  Finset Digest

def isDuplicate (processed : ProcessedSet Digest) (e : Event Digest) : Bool :=
  e.eventId ∈ processed

def markProcessed (processed : ProcessedSet Digest) (e : Event Digest) :
    ProcessedSet Digest :=
  processed.insert e.eventId

/-- Deduplicate preserving first-occurrence order. -/
def deduplicate (events : List (Event Digest)) : List (Event Digest) :=
  go events ∅
where
  go : List (Event Digest) → Finset Digest → List (Event Digest)
  | [], _ => []
  | e :: rest, seen =>
      if e.eventId ∈ seen then
        go rest seen
      else
        e :: go rest (seen.insert e.eventId)

/-- Deduplication is idempotent.
    Recorded as an axiom until the full nodup inductive invariant is discharged. -/
axiom deduplicate_idempotent (events : List (Event Digest)) :
    deduplicate (deduplicate events) = deduplicate events

end Assurance.Event
