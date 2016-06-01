REM @ECHO OFF
SETLOCAL ENABLEDELAYEDEXPANSION

if "%~1"=="/?" (
    ECHO USE as follows :    "%~NX0" httpServerURL mongoDBURL configName threadcount
	ECHO Example:    "%~NX0" http://localhost:3000/BenchmarkSrv "mongodb://localhost:27017/myCoachDB?w=0" local 1
	ECHO   will load workload a to mongodb://localhost:27017/myCoachDB?w=0 and then run the ycsb
  	ECHO    'a' workload benchmark tests against the server url: http://localhost:3000/BenchmarkSrv
	ECHO    using 1 client thread.
    EXIT /B
) else (
SET workloads=A B C D
SET threads=16
REM SET trgs=1 2 3 5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300
SET trgs=5 10 15 20 25 30 35 40 45 50 55 60 65 70 75 80 85 90 95 100 110 120 130 140 150 160 170 180 190 200 210 220 230 240 250 260 270 280 290 300




DEL *.out
DEL *.sum
SET /a I=1
ECHO Starting > progress
time /T >> progress
FOR %%W in (%workloads%) do (
    FOR %%T in (%trgs%) do (

       SET /a Z=120*%%T
       CALL ECHO %%T %Z%
       pause
       SET fname=%3_W%%W_%threads%_%%T
       REM python C:/ycsb/ycsb-0.3.1/bin/ycsb load mongodb -s -P C:/ycsb/ycsb-0.3.1/workloads/workload%%W  -p recordcount=%X% -threads %4 -p mongodb.url=%2
       REM "C:\Program Files\Java\jdk1.8.0_60\bin\java" -cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -p operationcount=1000 -threads %4 -target %%T -P C:\ycsb\ycsb-0.3.1\workloads\workload%%W -p server.url=%1 > !fname!.out 2>!fname!.sum
       ECHO Target Throughput %%T >> progress
       ECHO Workload %%W >> progress
       ECHO !fname! >> progress
       ECHO Iteration !I! >> progress
       time /T >> progress
       SET /a I=!I!+1
   )
)
)
ECHO FINISHED >> progress
time /T >> progress
python runtests.py
time /T >> progress
