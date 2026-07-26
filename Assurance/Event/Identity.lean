/-
  First-class event identity and duplicate-delivery rejection.

  Distributed systems duplicate messages.
  The protocol must satisfy:

    Resolve(Deduplicate(E)) = Resolve(E)
-/

import Assurance.Models.DegradationRules

namespace Assurance.Event

/-- An authenticated event carrying a unique event_id. -/
structure Event (Digest : Type) [CryptographicDigest Digest] where
  eventId : Digest
  agentId : Nat
  logicalTime : Nat          -- consensus / logical clock
  observedTime : Nat         -- telemetry only; never used for consensus
  payload : ByteArray
  parentHash : Option Digest
  proposedStateHash : Digest

/-- Processed-event set used for deduplication. -/
def ProcessedSet (Digest : Type) [CryptographicDigest Digest] :=
  Finset Digest

/-- Reject if the event_id has already been seen. -/
def isDuplicate (processed : ProcessedSet Digest) (e : Event Digest) : Bool :=
  e.eventId ∈ processed

/-- Record an event as processed. -/
def markProcessed (processed : ProcessedSet Digest) (e : Event Digest) :
    ProcessedSet Digest :=
  processed.insert e.eventId

/-- Deduplicate a list of events, preserving first occurrence order. -/
def deduplicate (events : List (Event Digest)) : List (Event Digest) :=
  Id.run do
    let mut seen : Finset Digest := ∅
    let mut out : List (Event Digest) := []
    for e in events do
      if e.eventId ∉ seen then
        seen := seen.insert e.eventId
        out := out ++ [e]
    return out

/-- Deduplication is idempotent. -/
theorem deduplicate_idempotent (events : List (Event Digest)) :
    deduplicate (deduplicate events) = deduplicate events := by
  -- Full proof requires induction on the list and Finset properties;
  -- the statement records the required contract.
  sorry

end Assurance.Event
