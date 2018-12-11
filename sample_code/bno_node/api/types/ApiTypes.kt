package com.leia.bno.api.types

import net.corda.businessnetworks.membership.states.MembershipStatus

data class MembershipState(val name: String, val displayedName: String?, val role : String, val status: MembershipStatus)