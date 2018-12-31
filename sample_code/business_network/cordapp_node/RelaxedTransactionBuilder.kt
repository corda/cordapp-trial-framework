// Build transactions which bypass contract constraints to always accept. 
// This can simplify deployments so that bug fix jars don't have to be 
// deployed to all nodes.
class RelaxedTransactionBuilder(notary : Party) : TransactionBuilder(notary) {

    fun withItemsNoConstraint(vararg items: Any): RelaxedTransactionBuilder {
        for (t in items) {
            when (t) {
                is StateAndContract -> addOutputState(t.state, t.contract, AlwaysAcceptAttachmentConstraint)
                else -> withItems(t)
            }
        }
        return this
    }

}