##############################################################################
# Created by Cormac Keogh ITT Dubli 2016
#
#
# Powershell Script to drive the YCSB client for benchmark tests agaisnt a 
# NodeJS nd MongoDB Server configuraion on Windows Azure.
# 
# M.Sc.in Mobile and Distributed Computing
###############################################################################



param(
#
# Uncomment out the server entrypoint you wish to run the tests against
#

  # [string]$server = "http://devmain.rowcatcher.com:3000/BenchmarkSrv",
  #   [string]$server = "http://tmdevmain.trafficmanager.net:3000/BenchmarkSrv",
    [string]$server = "http://lb2devmain.cloudapp.net/BenchmarkSrv",
  #  [string]$server = "http://rcdevmain.cloudapp.net:3000/BenchmarkSrv",
    [string]$mongoServer = "mongodb://rcdevmain.cloudapp.net:27018/myCoachDB?w=0",
    
    
    [string]$config = "devmain",
    [string]$threads = "256"
)


$java = "C:\Program Files\Java\jre1.8.0_77\bin\java"

cd C:\Users\Cormac\workspace\NoMoDbIL
$pythCmd = "python.exe"  
Write-Host "Arg: $server"
Write-Host "Arg: $mongoServer"
Write-Host "Arg: $config"
Write-Host "Arg: $threads"

$workloads=@("A","C","D") #,"C","D")
$maxTPutPerThread=32
$timeInSecs=240
$records=100000
net use x: /d
net use x: \\tsclient\C\Users\Cormac\workspace\NoMoDbIL

$Scenario = Read-Host -Prompt 'Input the Scenario Number'
$Description = Read-Host -Prompt 'Input a Description'


#####################################################################
# Code to query dynamically the Traffic Manager configuration
#####################################################################
#$azureAccountName = "devmain@rowcatcher.com"
#$azurePassword = ConvertTo-SecureString "Row12Catcher" -AsPlainText -Force
#$psCred = New-Object System.Management.Automation.PSCredential($azureAccountName, $azurePassword)
#Login-AzureRmAccount -Credential $psCred
#Login-AzureRmAccount 
#Get-AzureRmSubscription –SubscriptionId "007e82a9-093c-47c4-9b7d-52904eb47f3a" | Select-AzureRmSubscription

#Add-AzureAccount
#Get-AzureSubscription –SubscriptionId "007e82a9-093c-47c4-9b7d-52904eb47f3a" | Select-AzureSubscription
#Get-AzureTrafficManagerProfile 'tmdevmain' | out-file C:\Users\Cormac\workspace\NoMoDbIL\CurrentScenario.txt


   
$acttarget=0 
$i=0
$len=$trgTputsArr.length
$totalDuraction = $timeInSecs*$len
Write-Host "Total Test Duration Estimate (seconds): $totalDuraction"


$maxTPutPerThread=33
#$trgTputsArr=@(1,10,20,30,40,50,60,70,80,90,100,120,130,140,150,200,300,400,450,500,550,600,650,700,750,800,850,900,1000,1200,1400,1500,1600,1700,1800,1900,2000,2500,3000,3500,4000,4500,5000,5500,6000,7000,8000,9000,10000)
$trgTputsArr=@(10,100,200,300,400,500,600,800,1000,1400,1800,2200,2600,3000,3400,3800,4200,4400,5000,6000,7000,8000,9000,10000)

foreach ($w in $workloads) {

    #
    # Ensure the directory is clean from files from previous runs
    #
    Get-ChildItem -Path C:\Users\Cormac\workspace\NoMoDbIL\ -Include *.out -File -Recurse | foreach { $_.Delete()}
    Get-ChildItem -Path C:\Users\Cormac\workspace\NoMoDbIL\ -Include *.sum -File -Recurse | foreach { $_.Delete()}

    

    # LOAD THE DATA
    #
    # DO NOT DELETE THESE LINES
    #
    $args = "C:/ycsb/ycsb-0.3.1/bin/ycsb load mongodb -s -P C:/ycsb/ycsb-0.3.1/workloads/workload$w  -p recordcount=$records -p mongodb.url=$mongoServer"    
    start-process $pythCmd $args -Wait
    Write-Host "**Pausing for 3 mins ...allow for replication*"
    Start-Sleep -s 180  #pause for 3 minutes.

    'Workload:   ,'+$w | out-file C:\Users\Cormac\workspace\NoMoDbIL\CurrentScenario.txt 
    'Scenario:   ,'+$Scenario  | out-file C:\Users\Cormac\workspace\NoMoDbIL\CurrentScenario.txt -append
    'Description:   ,'+$Description | out-file C:\Users\Cormac\workspace\NoMoDbIL\CurrentScenario.txt -append
    'Server:   ,' + $server  | out-file C:\Users\Cormac\workspace\NoMoDbIL\CurrentScenario.txt -append
    'MongoDBServer:   ,' + $mongoServer | out-file C:\Users\Cormac\workspace\NoMoDbIL\CurrentScenario.txt -append    
    'Records:   ,'+$records | out-file C:\Users\Cormac\workspace\NoMoDbIL\CurrentScenario.txt -append
    'Run iteration time:   ,' + $timeInSecs | out-file C:\Users\Cormac\workspace\NoMoDbIL\CurrentScenario.txt -append



 #   $trgThreadsArr=@(24,26,28,30,32,34,36,38,40,42,44,46,48,50,52,54,56,58,60,62,190,210,230,250,270)
    $trgThreadsArr=@(130,150,170,190,210,230,250,270)
    $maxTPutPerThread=16  
    foreach ($threads in $trgThreadsArr) {                                    
       $ttputPerThread = $maxTPutPerThread
       $acttarget=$ttputPerThread*$threads 
       $dt = Get-Date

       $fname=$config+"_WrtConcern1_WorkLoad"+$w+"_Threads"+$threads+"_TrgServerTput"+$ttput+"_"+$dt.Day+"_"+$dt.Month +"_"+$dt.Year+"_"+$dt.Hour+"_"+$dt.Minute+"_"+$dt.Second
       #$args = "-cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -p operationcount=$ops -threads $threads -target $ttputPerThread -P C:\ycsb\ycsb-0.3.1\workloads\workload$w -p server.url=$server"
       $args = "-cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -p maxexecutiontime=$timeInSecs -threads $threads -target $ttputPerThread -P C:\ycsb\ycsb-0.3.1\workloads\workload$w -p server.url=$server"
       Write-Host "***************"#

       Write-Host "Actually targetting :" $acttarget
       Write-Host "Target TPUT per thread : $ttputPerThread"
       Write-Host "#Threads(client) : $threads"
          
       Write-Host "Arg: $args"
       Write-Host "Fname $fname"
       start-process $java $args -Wait -RedirectStandardError C:\Users\Cormac\workspace\NoMoDbIL\$fname.sum -RedirectStandardOutput C:\Users\Cormac\workspace\NoMoDbIL\$fname.out
       Write-Host "***************"
       $i=$i+1
	}

  $trgThreadsArr=@(25,30,35,40,45,50)
    $maxTPutPerThread=20  
    foreach ($threads in $trgThreadsArr) {                                    
       $ttputPerThread = $maxTPutPerThread
       $acttarget=$ttputPerThread*$threads 
       $dt = Get-Date

       $fname=$config+"_WrtConcern1_WorkLoad"+$w+"_Threads"+$threads+"_TrgServerTput"+$ttput+"_"+$dt.Day+"_"+$dt.Month +"_"+$dt.Year+"_"+$dt.Hour+"_"+$dt.Minute+"_"+$dt.Second     
       $args = "-cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -p maxexecutiontime=$timeInSecs -threads $threads -target $ttputPerThread -P C:\ycsb\ycsb-0.3.1\workloads\workload$w -p server.url=$server"
       Write-Host "***************"#

       Write-Host "Actually targetting :" $acttarget
       Write-Host "Target TPUT per thread : $ttputPerThread"
       Write-Host "#Threads(client) : $threads"
          
       Write-Host "Arg: $args"
       Write-Host "Fname $fname"
       start-process $java $args -Wait -RedirectStandardError C:\Users\Cormac\workspace\NoMoDbIL\$fname.sum -RedirectStandardOutput C:\Users\Cormac\workspace\NoMoDbIL\$fname.out
       Write-Host "***************"
       $i=$i+1
	}




    
    foreach ($ttput in $trgTputsArr) {                         
       
       [int]$threads=($ttput/$maxTPutPerThread)+1       
       [double]$ttputPerThread=($ttput -as [double])/($threads -as [double])       
       $ttputPerThread = [math]::floor($ttputPerThread) 
       $ops=$timeInSecs*$ttputPerThread      
       $ops = [math]::floor($ops) 
         
       while($ttput -gt $ttputPerThread*$threads)
       {
            $threads++
       }   

       $acttarget=$ttputPerThread*$threads 
       
       $dt = Get-Date

       $fname=$config+"_WrtConcern1_WorkLoad"+$w+"_Threads"+$threads+"_TrgServerTput"+$ttput+"_"+$dt.Day+"_"+$dt.Month +"_"+$dt.Year+"_"+$dt.Hour+"_"+$dt.Minute+"_"+$dt.Second
       
       $args = "-cp C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\Users\Cormac\workspace\NoMoDbIL\bin\nomo.jar;C:\ycsb\ycsb-0.3.1\conf;C:\ycsb\ycsb-0.3.1\lib\core-0.3.1.jar;C:\ycsb\ycsb-0.3.1\lib\HdrHistogram-2.1.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-core-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\jackson-mapper-asl-1.9.4.jar;C:\ycsb\ycsb-0.3.1\lib\tmp\core-0.3.1.jar com.yahoo.ycsb.Client -db com.nomodb.NoMoDbIL -s -p maxexecutiontime=$timeInSecs -threads $threads -target $ttputPerThread -P C:\ycsb\ycsb-0.3.1\workloads\workload$w -p server.url=$server"
       Write-Host "***************"
       Write-Host "Total Target TPUT: $ttput"
       Write-Host "Actually targetting :" $acttarget
       Write-Host "Target TPUT per thread : $ttputPerThread"
       Write-Host "#Threads(client) : $threads"
       Write-Host "#Operations : $ops"       
       Write-Host "Should take $timeInSecs seconds"
       Write-Host "Arg: $args"
       Write-Host "Fname $fname"
       start-process $java $args -Wait -RedirectStandardError C:\Users\Cormac\workspace\NoMoDbIL\$fname.sum -RedirectStandardOutput C:\Users\Cormac\workspace\NoMoDbIL\$fname.out
       #start-process $java $args -Wait 
       Write-Host "***************"
       $i=$i+1
	}
    start-process $pythCmd C:\Users\Cormac\workspace\NoMoDbIL\aggregateResults.py -Wait
}




