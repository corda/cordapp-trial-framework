# Cordapp Testing Best Practices
There are two main ways in which the trial Cordapp should be tested. This is an investment which should be planned for at the beginning of Cordapp development. The time spent developing tests will pay dividends in:
* Reduced testing effort
* Increased agility for late changes to the Cordapp from business scope changes
* Increased confidence in the quality of the Cordapp + web services

## Unit Tests
TODO

## Integration Tests
Testing the application is isolation is fine for development but live Corda nodes must be tested along with the web services. This must be done using running nodes which can either be on a local development machine or a cloud VM.

The goal of an integration test is to ensure that each step of the trial use case can be invoked in order using actual JSON, RESTful http calls and Corda flows. An example script hass been provided [here](../sample_code/testing/sample_integration_tests.sh)

### Establish a Corda Network
In order run the integration tests you must bootstrap a Corda Network on your test environment. This network will consist of:
* N nodes where n is the minimum number of roles that is required to run the trial use case
* Notary
* BNMS

For development purposes this can be done simply by using `runnodes` to begin with.

### Establish Business Network Membership
For each node in your test network, request membership within the test business network. This is one http call to apply for membership and a second http call to ensure the membership is recorded. In both cases compare the response with what was expected to ensure the application behaved correctly.

This must be done first as any other requests should be rejected if a node is not a member in the business network.

### Execute the Trial Use Case
Run a Corda transaction for each step in the trial use case in the order you expect it to run.

1. Make an http call to the web server which initiates the flow which facilitates the transaction
2. Make a second http call to the web server to verify that the ledger contains the state that is expected to be recorded.

In both cases ensure the the response from the application matches what was expected. Fail early and often as generally each future step relies on the output of the previous step.

Generally each transaction requires dummy JSON data. Example data is provided [here](../sample_data) for both membership requests and state issuance. You will need to modify these files to match your specific use case.

