    @POST
    @Path("defaultAttestation")
    fun getDefaultAttestation(): Response {
        return try {
            val roles = getPartiesOnThisBusinessNetwork().filter {
                it.membershipMetadata.role.equals(<your role>,true)
            }.map { it.party }
            if(roles.size > 1) {
                return Response.status(NOT_FOUND).entity("Too many roles found in Business Network").build()
            }
            val role = roles.firstOrNull()
            if(role == null) {
                return Response.status(NOT_FOUND).entity("Role not found in Business Network").build()
            }
            logger.info("Going to use this role: $role")

            ....
    }

    private fun getPartiesOnThisBusinessNetwork() : List<PartyAndMembershipMetadata> {
        val flowHandle = services.startTrackedFlow(::GetMembersFlow,false)
        return flowHandle.returnValue.getOrThrow()
    }