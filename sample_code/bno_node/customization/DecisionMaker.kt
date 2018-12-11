package com.leia.bno.customization

import net.corda.businessnetworks.membership.bno.extension.BNODecisionMaker
import net.corda.businessnetworks.membership.states.Membership

class DecisionMaker() : BNODecisionMaker {

    override fun autoActivateThisMembership(membershipState: Membership.State): Boolean {
        return listOf("customer","bank","attester","datastore").contains(membershipState.membershipMetadata.role.toLowerCase())
    }
}