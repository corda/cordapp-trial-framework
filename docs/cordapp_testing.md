# Cordapp Testing Best Practices
There are two main ways in which the trial Cordapp should be tested. This is an investment which should be planned for at the beginning of Cordapp development. The time spent developing tests will pay dividends in:
* Reduced testing effort
* Increased agility for late changes to the Cordapp from business scope changes
* Increased confidence in the quality of the Cordapp + web services

## Unit Tests
Testing the application at the component level which include the state, contract and flow. As your application gets more complex, unit testing helps prevent regression especially on edge cases or bugs previously identified. For more examples, you can take a look on the approaches taken in the sample CorDapps (https://github.com/corda/samples).

## Integration Tests and System Tests
Testing the application is isolation is fine for development but live Corda nodes must be tested along with the web services. This must be done using running nodes which can either be on a local development machine or a cloud VM.

The goal of an integration test is to ensure that each step of the trial use case can be invoked in order using actual JSON, RESTful http calls and Corda flows. An example script hass been provided [here](../sample_code/testing/sample_integration_tests.sh)

### Establish a Corda Network
In order run the integration or systems tests you must bootstrap a Corda Network on your test environment. This network will consist of:
* N nodes where n is the minimum number of roles that is required to run the trial use case
* Notary
* (optional) BNMS

For development purposes this can be done simply by using `runnodes` to begin with or using the `network bootstrapper tool` (https://docs.corda.net/docs/corda-os/4.4/network-bootstrapper.html)

### Execute the Trial Use Case
Run a Corda transaction for each step in the trial use case in the order you expect it to run.

1. Make an http call to the web server which initiates the flow which facilitates the transaction
2. Make a second http call to the web server to verify that the ledger contains the state that is expected to be recorded.

In both cases ensure the the response from the application matches what was expected. Fail early and often as generally each future step relies on the output of the previous step.

Generally each transaction requires dummy JSON data. Example data is provided [here](../sample_data) for both membership requests and state issuance. You will need to modify these files to match your specific use case.

### End to end testing at systems level
Deploy the trial application to Testnet or Pre-prod and test the use case end to end. Application behaviour on a network may vary from local testing. R3 will provide guidance on testing best practices and will provide a list of assessment criteria to assist in the scope.

Once the application is stable it should be tested for:
* Load/Soak: execute the business use case many times to load 100s or 1000s of transactions to ensure the services continue to function correctly. The quantity of transactions necessary to test will depend on the use case.
* Stress: execute the business use case many times in parallel as many participants may use the trial application simultanesouly. The max throughput is generally not high and will depend on the use case and the number of trial participants. This test is especially important if your architecture involves some centralisation such that it may become the central point of failure.
* Performance: ensure the application is responsive to single usage. This does not mean a high number of transactions per second but rather that the application is engaging. For example, you do not want your participants to wait 5mins on the UI following each action.