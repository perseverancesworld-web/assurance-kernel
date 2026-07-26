namespace Assurance.Event

structure Event (Digest : Type) [DecidableEq Digest] where
  eventId : Digest
  agentId : Nat
  logicalTime : Nat
  observedTime : Nat
  proposedStateHash : Digest

def memId (seen : List Digest) (id : Digest) : Bool :=
  match seen with
  | [] => false
  | x :: xs => decide (x = id) || memId xs id

def isDuplicate (seen : List Digest) (e : Event Digest) : Bool :=
  memId seen e.eventId

def markProcessed (seen : List Digest) (e : Event Digest) : List Digest :=
  e.eventId :: seen

def deduplicate (events : List (Event Digest)) : List (Event Digest) :=
  go events []
where
  go : List (Event Digest) → List Digest → List (Event Digest)
  | [], _ => []
  | e :: rest, seen =>
      if memId seen e.eventId then go rest seen
      else e :: go rest (e.eventId :: seen)

end Assurance.Event
