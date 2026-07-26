namespace Assurance.Event

structure Event (Digest : Type) [DecidableEq Digest] where
  eventId : Digest
  agentId : Nat
  logicalTime : Nat
  observedTime : Nat
  proposedStateHash : Digest

def isDuplicate (seen : List Digest) (e : Event Digest) : Bool :=
  seen.contains e.eventId

def markProcessed (seen : List Digest) (e : Event Digest) : List Digest :=
  e.eventId :: seen

def deduplicate (events : List (Event Digest)) : List (Event Digest) :=
  go events []
where
  go : List (Event Digest) → List Digest → List (Event Digest)
  | [], _ => []
  | e :: rest, seen =>
      if seen.contains e.eventId then go rest seen
      else e :: go rest (e.eventId :: seen)

end Assurance.Event
