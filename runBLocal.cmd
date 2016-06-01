REM python ./bin/ycsb run -db com.nomodb.NoMoDbIL -cp C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar -s -P workloads/workloada

REM bpython ./bin/ycsb run -db nomodb -s -P workloads/workloada 

"C:\Program Files\Java\jdk1.8.0_60\bin\java" -cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar:C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\nomodb-binding\conf;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -P C:/ycsb/ycsb-0.3.1/workloads/workloadb -p server.url=%1 > %0.out

