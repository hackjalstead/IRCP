<######################################################################

            Incident Response Collection Protocol (IRCP)
                        Live Version
    ! Edit the KAPE parsers below depending on investigational needs!
    ! For multiple KAPE parsers use a comma to seperate the values !

#######################################################################>

####################### KAPE Targets & Modules ########################

                $kapeWorkstationTargets = "!SANS_Triage"
                $kapeServerTargets = "!SANS_Triage,ServerTriage"
                $kapeModules = "!EZParser"

#######################################################################

####### TRANSCRIPT AND TITLE
Start-Transcript .\ircpLiveConsole.log | out-null
Clear-Host
$ircp = "@
                `$`$`$`$`$`$\ `$`$`$`$`$`$`$\   `$`$`$`$`$`$\  `$`$`$`$`$`$`$\
                \_`$`$  _|`$`$  __`$`$\ `$`$  __`$`$\ `$`$  __`$`$\
                  `$`$ |  `$`$ |  `$`$ |`$`$ /  \__|`$`$ |  `$`$ |
                  `$`$ |  `$`$`$`$`$`$`$  |`$`$ |      `$`$`$`$`$`$`$  |
                  `$`$ |  `$`$  __`$`$  `$`$ |      `$`$  ____/
                  `$`$ |  `$`$ |  `$`$ |`$`$ |  `$`$\ `$`$ |
                `$`$`$`$`$`$\ `$`$ |  `$`$ |\`$`$`$`$`$`$  |`$`$ |
                \______|\__|  \__| \______/ \__|
@"
Write-Host $ircp
Write-Host -ForegroundColor Yellow "============ Incident Response Collection Protocol ============"
Write-Host ""

####### VARIABLE DECLARATION & LIVE HOST DRIVE SELECTION
Write-Host -ForegroundColor Yellow "============ Select the Live Host OS Drive"
Write-Host ""
Start-Sleep -Seconds 2
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.FolderBrowserDialog
$browser.RootFolder = 'MyComputer'
$browser.Description = "Select the Live Host OS Drive"
$null = $browser.ShowDialog()
$targetDrive = $browser.SelectedPath
$os = Get-wmiobject -class win32_operatingsystem
$osInfo = $os.productType
Write-Host -ForegroundColor Yellow "============ $targetDrive Selected on $env:computername"
Write-Host ""
Start-Sleep -Seconds 2

####### CREATE COLLECTION DIRECTORIES
Write-Host -ForegroundColor Yellow "==============================================================="

$PathExists = Test-Path Evidence
If ($PathExists -eq $false) {
    mkdir Evidence | out-null }
Set-Location Evidence

$PathExists = Test-Path $env:computername
If ($PathExists -eq $false) {
    mkdir $env:computername | out-null }

$PathExists = Test-Path $env:computername\Modules
If ($PathExists -eq $false) {
    mkdir $env:computername\Modules | Out-Null }

$PathExists = Test-Path $env:computername\Targets
If ($PathExists -eq $false) {
    mkdir $env:computername\Targets | out-null }

Write-Host ""
Write-Host -ForegroundColor Yellow "============ .\Evidence\$env:computername\Targets"
Write-Host -ForegroundColor Yellow "============ .\Evidence\$env:computername\Modules"
Write-Host ""
Write-Host -ForegroundColor Yellow "============ Evidence Collection Folders Created"
Write-Host ""
Write-Host -ForegroundColor Yellow "==============================================================="
Start-Sleep -Seconds 2

####### OS INFORMATION - LIVE VERSION ONLY
Write-Host ""
Write-Host -ForegroundColor Yellow "============ Collecting $env:COMPUTERNAME OS Information"
Write-Host ""
Start-Sleep -Seconds 2
Get-ComputerInfo > $env:computername\OS_Information.txt
Set-Location ..

if ($osInfo -eq 1) {
    Write-Host -ForegroundColor Yellow "============ IRCP Detected $env:COMPUTERNAME as a Workstation"
    Write-Host ""
}
elseif ($osInfo -eq 2 -Or 3) {
        Write-Host -ForegroundColor Yellow "============ IRCP Detected $env:COMPUTERNAME as a Server"
        Write-Host ""
}

####### KAPE Execution
if ($osInfo -eq 1) {
    Write-Host -ForegroundColor Yellow "============ Executing KAPE for Workstation"
    Write-Host ""
    Start-Sleep -Seconds 1
    kape\kape.exe --tsource $targetDrive --tdest Evidence\$env:COMPUTERNAME\Targets --target $kapeWorkstationTargets --zip $env:COMPUTERNAME --module $kapeModules,RECmd_BasicSystemInfo Evidence\$env:COMPUTERNAME\Targets\$targetDrive --mdest Evidence\$env:computername\Modules
    }
elseif ($osInfo -eq 2 -Or 3) {
    Write-Host -ForegroundColor Yellow "============ Executing KAPE for Server"
    Write-Host ""
    Start-Sleep -Seconds 1
    kape\kape.exe --tsource $targetDrive --tdest Evidence\$env:COMPUTERNAME\Targets --target $kapeServerTargets --zip $env:COMPUTERNAME --module $kapeModules,RECmd_BasicSystemInfo --msource --msource Evidence\$env:COMPUTERNAME\Targets\$targetDrive --mdest Evidence\$env:computername\Modules
    }
else {
    Write-Host -ForegroundColor Yellow "============ Error Please Start Again"
    Write-Host ""
    return
}

####### COLLECTION COMPLETE
Write-Host -ForegroundColor Yellow "============ Incident Response Collector Protocol Completed Collection ============"
Stop-Transcript | out-null
Move-Item -Path .\Evidence\$env:COMPUTERNAME\Modules\Registry\*_BasicSystemInfo_Output.csv .\Evidence\$env:COMPUTERNAME\TargetSystemInfo.csv
Move-Item -Path .\Evidence\$env:COMPUTERNAME\Modules\*.txt -Destination .\Evidence\$env:COMPUTERNAME\kapeModules.log
Move-Item -Path .\Evidence\$env:COMPUTERNAME\Targets\*.txt -Destination .\Evidence\$env:COMPUTERNAME\kapeTargets.log
Move-Item -Path .\ircpLiveConsole.log -Destination .\Evidence\$env:COMPUTERNAME\ircpLiveConsole.log
Pause