package com.leia.bno.api

import com.fasterxml.jackson.databind.SerializationFeature
import com.fasterxml.jackson.jaxrs.annotation.JacksonFeatures
import com.leia.bno.api.types.MembershipState
import com.leia.bno.exception.PartyNotFoundException
import net.corda.businessnetworks.membership.bno.ActivateMembershipForPartyFlow
import net.corda.businessnetworks.membership.bno.RevokeMembershipForPartyFlow
import net.corda.businessnetworks.membership.states.Membership
import net.corda.core.identity.CordaX500Name
import net.corda.core.identity.Party
import net.corda.core.messaging.CordaRPCOps
import net.corda.core.messaging.startTrackedFlow
import net.corda.core.utilities.getOrThrow
import net.corda.core.utilities.loggerFor
import org.slf4j.Logger
import javax.ws.rs.*
import javax.ws.rs.core.MediaType
import javax.ws.rs.core.Response

@Path("businessnetwork")
@Produces(MediaType.APPLICATION_JSON)
class BnoApi(val services: CordaRPCOps) {
    private val myLegalName = services.nodeInfo().legalIdentities.first().name

    companion object {
        private val logger: Logger = loggerFor<BnoApi>()
    }

    @GET
    @Path("states")
    @Produces(MediaType.APPLICATION_JSON)
    @JacksonFeatures(serializationEnable = arrayOf(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS))
    fun getMembershipStates(): Response {
        return try {
            logger.info("Returning all states")
            val membershipStates = services.vaultQuery(Membership.State::class.java).states.map { MembershipState(it.state.data.member.name.toString(),it.state.data.membershipMetadata.alternativeName,it.state.data.membershipMetadata.role,it.state.data.status ) }
            Response.status(Response.Status.OK).entity(membershipStates).build()
        } catch (ex: Throwable) {
            logger.error(ex.message, ex)
            Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(ex.message!!).build()
        }
    }

    @POST
    @Path("activate")
    @Produces(MediaType.APPLICATION_JSON)
    @JacksonFeatures(serializationEnable = arrayOf(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS))
    fun activateMembership(name : String): Response {
        return try {
            logger.info("Looking for party $name")
            val party = findPartyForName(name)
            val flowHandle = services.startTrackedFlow(::ActivateMembershipForPartyFlow,party)
            val result = flowHandle.returnValue.getOrThrow()
            Response.status(Response.Status.OK).entity("Transaction id ${result.id} committed to ledger.\n").build()
        } catch (ex: Throwable) {
            logger.error(ex.message, ex)
            Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(ex.message!!).build()
        }
    }

    @POST
    @Path("revoke")
    @Produces(MediaType.APPLICATION_JSON)
    @JacksonFeatures(serializationEnable = arrayOf(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS))
    fun revokeMembership(name: String): Response {
        return try {
            logger.info("Looking for party $name")
            val party = findPartyForName(name)
            val flowHandle = services.startTrackedFlow(::RevokeMembershipForPartyFlow, party)
            val result = flowHandle.returnValue.getOrThrow()
            Response.status(Response.Status.OK).entity("Transaction id ${result.id} committed to ledger.\n").build()
        } catch (ex: Throwable) {
            logger.error(ex.message, ex)
            Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(ex.message!!).build()
        }
    }

    private fun findPartyForName(name : String) : Party {
        return services.wellKnownPartyFromX500Name(CordaX500Name.parse(name)) ?: throw PartyNotFoundException(name)
    }


}