# Cormac Keogh

import argparse
import fnmatch
import io
import os
import re
import shlex
import sys
import subprocess
import csv
import time

threads = 1
target = 1
workload = 'A'
configName = 'local'
runTime = 0
actualTput = 0
averageLatency = 0
operation = ""
numOperations = 0
minLatency = 0
maxLatency = 0
percentile95Latency = 0
percentile99Latency = 0

def WriteOutRecord(csvWriter):
    global threads
    global target
    global workload
    global configName
    global runTime
    global actualTput
    global averageLatency
    global operation
    global numOperations
    global minLatency
    global maxLatency
    global percentile95Latency
    global percentile99Latency

    totaltput = actualTput*float(threads);
    csvWriter.writerow([configName, workload, threads, target,actualTput, totaltput,averageLatency,operation,numOperations,minLatency,maxLatency,percentile95Latency,percentile99Latency])



def processline2(line):
   global threads
   global target

   threadsStr = line.split("threads",1)[1]
   threads = threadsStr.split(' ')[1]

   targetStr = line.split("target",1)[1]
   target = targetStr.split(' ')[1]

def processFileName(name):
   global workload
   global configName

   configName = name.split("_")[0]
   workload = name.split("_")[1]



def processfile(inFile,writer):
    global threads
    global target
    global workload
    global configName
    global runTime
    global actualTput
    global averageLatency
    global operation
    global numOperations
    global minLatency
    global maxLatency
    global percentile95Latency
    global percentile99Latency

    i=1

    processFileName(inFile)

    with open(inFile, "r") as ifile:
        for line in ifile:
            print line
            if not line:
                break

            if(i == 2):
                processline2(line)
            else:
                if(line.find('{')!=1):  # continue looking
                    if(line.find('[READ]')!=-1):
                        operation = "READ"
                    if(line.find('[UPDATE]')!=-1):
                        operation = "UPDATE"
                    if(line.find('[CLEANUP]')!=-1):
                        operation = "CLEANUP"

                    if(line.find('[OVERALL], RunTime(ms)')!=-1):
                        runTime = float(line.split(",")[2].strip())
                    if(line.find('[OVERALL], Throughput(ops/sec)')!=-1):
                        actualTput = float(line.split(",")[2].strip())

                    if(line.find('AverageLatency(us')!=-1):
                        averageLatency = float(line.split(",")[2].strip())
                    if(line.find('Operations,')!=-1):
                        numOperations = float(line.split(",")[2].strip())
                    if(line.find(', MinLatency(us)')!=-1):
                        minLatency = float(line.split(",")[2].strip())
                    if(line.find(', MaxLatency(us)')!=-1):
                        maxLatency = float(line.split(",")[2].strip())
                    if(line.find(', 95thPercentileLatency')!=-1):
                        percentile95Latency = float(line.split(",")[2].strip())
                    if(line.find(', 99thPercentileLatency')!=-1):
                        percentile99Latency = float(line.split(",")[2].strip())
                    if(line.find(', Return=')!=-1):
                        WriteOutRecord(writer)

            i=i+1



# Open a file
list = os.listdir(".")

curDateTime = time.strftime("%c")
curDateTime = curDateTime.replace('/','_')
curDateTime = curDateTime.replace(' ','_')
curDateTime = curDateTime.replace(':','-')
outfileName = configName + '_' + workload + '_' + str(threads) + '_' + str(target) + '_DT' +curDateTime + '.csv'



csvOutfile = open(outfileName, "w")
csvWriter = csv.writer(csvOutfile)
csvWriter.writerow(['configName', 'workload','threads', 'target','actualTput', 'actualTput Total','averageLatency','operation','numOperations','minLatency','maxLatency','percentile95Latency','percentile99Latency'])

for fname in list:
    if fname.endswith(".out"):
        processfile(fname,csvWriter)


csvOutfile.close()



#cmd = "python C:/ycsb/ycsb-0.3.1/bin/ycsb load mongodb -s -P C:/ycsb/ycsb-0.3.1/workloads/workloada  -p recordcount=10000 -threads 16 -p mongodb.url=mongodb://localhost:27017/myCoachDB?w=0"
#p = subprocess.Popen(cmd)
#p.communicate(input=None);
#cmd = "'C:\Program Files\Java\jdk1.8.0_60\bin\java' -cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -p operationcount=10000 -threads %5 -target %6 -P C:\ycsb\ycsb-0.3.1\workloads\workload%3 -p server.url=http://localhost:3000/http://localhost:3000/BenchmarkSrv > localA.out 2>localA.sum"
#subprocess.call(cmd)