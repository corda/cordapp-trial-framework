    @POST
    @Path("membership/request")
    @Produces(MediaType.APPLICATION_JSON)
    fun requestMembership(membershipRequest: MembershipRequest): Response {
        return try {
            val flowHandle = services.startTrackedFlow(::RequestMembershipFlow,MembershipMetadata(membershipRequest.role,membershipRequest.displayedName))
            val result = flowHandle.returnValue.getOrThrow()
            Response.status(Response.Status.OK).entity("Transaction id ${result.id} committed to ledger.\n").build()
        } catch (ex: Throwable) {
            logger.error(ex.message, ex)
            Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(ex.message!!).build()
        }
    }

    @GET
    @Path("membership/status")
    @Produces(MediaType.APPLICATION_JSON)
    @JacksonFeatures(serializationEnable = arrayOf(SerializationFeature.WRITE_DATES_AS_TIMESTAMPS))
    fun getMembershipStatus(): Response {
        return try {
            logger.info("Returning this node's membership status")
            val membershipState = getMembershipState()
            Response.status(Response.Status.OK).entity(com.leia.base.api.types.MembershipStatus(membershipState.status)).build()
        } catch (ex: Throwable) {
            logger.error(ex.message, ex)
            Response.status(Response.Status.INTERNAL_SERVER_ERROR).entity(ex.message!!).build()
        }
    }

    private fun getMembershipState() : Membership.State {
        val membershipStates = services.vaultQuery(Membership.State::class.java).states.filter { it.state.data.member == services.nodeInfo().legalIdentities.first() }
        when {
            membershipStates.isEmpty() -> throw RuntimeException("No membership state found")
            membershipStates.size > 1 -> throw RuntimeException("Found more than one membership sate") //this should never happen
            else -> return membershipStates.get(0).state.data
        }
    }
