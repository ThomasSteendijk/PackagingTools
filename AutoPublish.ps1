<#
.SYNOPSIS
  Auto-publish most recent App-V

.DESCRIPTION
  Publishes the most recent appv files in $SearchFolder for quick testing
  
.INPUTS
  $SearchFolder        In this folder (en deeper) the scripts looks for AppV files, then picks the most recent version and publishes it
                      
  $TargetLocalFolder   Target location used to store the found most recent file before publishing the AppV


.OUTPUTS
  Log files will be written to $SearchFolder\AutoPublish.log


.NOTES
  Version:        0.1
  Author:         Thomas Steendijk
  Creation Date:  26-10-2018
   
#>



$SearchFolder = "(network)path\to\storage\location"
$TargetLocalFolder = "$env:TEMP\TempPublishStorage"

Enable-Appv
    if (Test-Path $TargetLocalFolder) {} else {mkdir $TargetLocalFolder}

$latestInstaller = (Get-ChildItem $SearchFolder -Exclude Finished -Directory) | Get-ChildItem -Recurse -Filter *.appv | Where-Object {$_.LastWriteTime -gt (Get-Date).AddMinutes(-120)} | Sort-Object -Property LastWriteTime | select -last 1

Copy-Item $latestInstaller.fullname -Destination $TargetLocalFolder
Echo "Publishing $($latestInstaller.fullname)"
Add-AppvClientPackage (Get-ChildItem $TargetLocalFolder -Filter *.appv ).FullName | Mount-AppvClientPackage | Publish-AppvClientPackage -Global

#write log
$currentDate = (Get-Date -UFormat "%d-%m-%Y")
$currentTime = (Get-Date -UFormat "%T")
$logOutput = $logOutput -join (" ")
"[$currentDate $currentTime] Used File $($latestInstaller.fullname)" | Out-File $SearchFolder\AutoPublish.log -Append

