import Assurance.Trust.Controller

namespace Assurance.Trust

theorem cannot_propose_when_quarantined :
    mayPropose .quarantined = false := rfl

theorem revoked_terminal (e : TrustEvidence) :
    evolve .revoked e = .revoked :=
  revoked_is_absorbing e

end Assurance.Trust
