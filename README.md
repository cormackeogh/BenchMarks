git commit## Quick Start

This section shows how to run YCSB against NodeJS and MongoDB. 

### Run the tests against Node and MongoDB instance

First, update the powershell script to point at the endpoint of your 
server configuration. Then open a powershell prompt in the directory where RunBEnchmarkNew.ps1 
exists and type:

	./runBenchmark.ps1

This will loop through all of the cases and selected Workloads and call the YCSB.
Ensure that the NoMoDbIL.class file is being loaded by the YCSB client.

The script will also called the AggregateResults python script to create the CSV file 
which has the entire results for this test run.

Cormac Keogh
ITTDublin
