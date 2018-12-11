    @POST
    @Path("defaultAttestation")
    fun getDefaultAttestation(): Response {
        return try {
            val attesters = getPartiesOnThisBusinessNetwork().filter {
                it.membershipMetadata.role.equals("attester",true)
            }.map { it.party }
            if(attesters.size > 1) {
                return Response.status(NOT_FOUND).entity("Too many attesters found in Business Network").build()
            }
            val attester = attesters.firstOrNull()
            if(attester == null) {
                return Response.status(NOT_FOUND).entity("Attester not found in Business Network").build()
            }
            logger.info("Going to use this attester: $attester")

            val datastores = getPartiesOnThisBusinessNetwork().filter {
                it.membershipMetadata.role.equals("datastore",true)
            }.map { it.party }
            if(datastores.size > 1) {
                return Response.status(NOT_FOUND).entity("Too many datastores found in Business Network").build()
            }
            val datastore = datastores.firstOrNull()
            if(datastore == null) {
                return Response.status(NOT_FOUND).entity("Datastore not found in Business Network").build()
            }
            logger.info("Going to use this datastore: $datastore")
            ....
    }

    private fun getPartiesOnThisBusinessNetwork() : List<PartyAndMembershipMetadata> {
        val flowHandle = services.startTrackedFlow(::GetMembersFlow,false)
        return flowHandle.returnValue.getOrThrow()
    }