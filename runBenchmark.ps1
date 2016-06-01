param(
    [string]$server = "http://devmain.rowcatcher.com:3000/BenchmarkSrv",
    [string]$mongoServer = "mongodb://localhost:27017/myCoachDB?w=0",
    [string]$config = "local",
    [string]$threads = "256"
)
Write-Host "Arg: $server"
Write-Host "Arg: $mongoServer"
Write-Host "Arg: $config"
Write-Host "Arg: $threads"

$workloads=@("A") # ,"B","C","D")
#$trgs=@(5,10,15,20,25,30,35,40,45,50,55,60,65,70,75,80,85,90,95,100,110,120,130,140,150,160,170,180,190,200,210,220,230,240,250,260,270,280,290,300)
#$trgs=@(20,40,80,120,160,200,240,280,300)
#$trgTputs=@(6000,12000,24000,36000,48000,60000,72000,84000,90000)
$trgTputsArr=@(100,100,10,20,30,40,50,60,70,80,90,100,150,200,250,300,350,400,450,500,600,700,800,900,1000)
$threadsArr= @(  2,  2, 1, 1, 1, 1, 1, 1, 1, 1, 1,  1,  2,  2,  3,  3,  3,  4, 5,  5,  6,  7,  8,  9, 10)



Get-ChildItem -Path C:\Users\Cormac\workspace\NoMoDbIL\ -Include *.out -File -Recurse | foreach { $_.Delete()}
Get-ChildItem -Path C:\Users\Cormac\workspace\NoMoDbIL\ -Include *.sum -File -Recurse | foreach { $_.Delete()}

$records=10000000


foreach ($w in $workloads) {

    
    $pythCmd = "python.exe"
    $args = "C:/ycsb/ycsb-0.3.1/bin/ycsb load mongodb -s -P C:/ycsb/ycsb-0.3.1/workloads/workload$w  -p recordcount=$records -threads $threads -p mongodb.url=$mongoServer"    
    #start-process $pythCmd $args -Wait

    $i=0
    foreach ($ttput in $trgTputsArr) {       
       
       $threads=$threadsArr[$i]
       $t=$ttput/$threads
       $ops=600*$t       
       
       $fname=$config+"_WrtConcern1_WorkLoad"+$w+"_Threads"+$threadsArr[$i]+"_TrgServerTput"+$ttput

       $java = "C:\Program Files\Java\jdk1.8.0_60\bin\java"
       $args = "-cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -p operationcount=$ops -threads $threads -target $t -P C:\ycsb\ycsb-0.3.1\workloads\workload$w -p server.url=$server"
       Write-Host "Arg: $args"
       start-process $java $args -Wait -RedirectStandardError C:\Users\Cormac\workspace\NoMoDbIL\$fname.sum -RedirectStandardOutput C:\Users\Cormac\workspace\NoMoDbIL\$fname.out

       $i=$i+1
	}
}

$pythCmd = "python.exe"
$args = "C:\Users\Cormac\workspace\NoMoDbIL\runtests.py"
start-process $pythCmd $args -Wait

