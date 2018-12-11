    @InitiatedBy(Initiator::class)
    class Acceptor(flowSession: FlowSession) : BusinessNetworkAwareInitiatedFlow<SignedTransaction>(flowSession) {
        @Suspendable
        override fun onOtherPartyMembershipVerified(): SignedTransaction {
            val signTransactionFlow = object : SignTransactionFlow(flowSession) {
                override fun checkTransaction(stx: SignedTransaction) = requireThat {
                    "Must be signed by the initiator" using (stx.sigs.any())

                    // check the transaction for correctness

                    stx.verify(serviceHub, false)
                }
            }

            return subFlow(signTransactionFlow)
        }
    }
