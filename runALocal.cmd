


 "C:\Program Files\Java\jdk1.8.0_60\bin\java" -cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -p operationcount=10000 -threads 16 -P C:\ycsb\ycsb-0.3.1\workloads\workload%2 -p server.url=%1 > %0.out

