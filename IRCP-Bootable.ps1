<######################################################################

            Incident Response Collection Protocol (IRCP)
                        Bootable Version
    ! Edit the KAPE parsers below depending on investigational needs!
    ! For multiple KAPE parsers use a comma to seperate the values !

#######################################################################>

####################### KAPE Targets & Modules ########################

                $kapeWorkstationTargets = "!SANS_Triage"
                $kapeServerTargets = "!SANS_Triage,ServerTriage"
                $kapeModules = "!EZParser"

#######################################################################

####### TRANSCRIPT AND TITLE
Start-Transcript .\ircpBootableConsole.log | out-null
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

####### OS DRIVE SELECTION
Write-Host -ForegroundColor Yellow "============ Select the OS Drive"
Write-Host ""
Start-Sleep -Seconds 2
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.FolderBrowserDialog
$browser.RootFolder = 'MyComputer'
$browser.Description = "Select the OS Drive"
$null = $browser.ShowDialog()
$srcDrive = $browser.SelectedPath
Write-Host -ForegroundColor Yellow "============ $srcDrive Selected"
Write-Host ""
Start-Sleep -Seconds 2

####### SELECT DESTINATION DRIVE
Write-Host -ForegroundColor Yellow "============ Select the Destination Drive"
Write-Host ""
Start-Sleep -Seconds 2
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.FolderBrowserDialog
$browser.RootFolder = 'MyComputer'
$browser.Description = "Select the Destination Drive"
$null = $browser.ShowDialog()
$dstDrive = $browser.SelectedPath
Write-Host -ForegroundColor Yellow "============ $dstDrive Selected"
Write-Host ""
Start-Sleep -Seconds 2

$hostName  = & kape\Modules\bin\RECmd\RECmd.exe --f $srcDrive\Windows\System32\config\SYSTEM --nl --kn ControlSet001\Control\ComputerName\ComputerName\ --vn ComputerName
$hostNameRegex = [Regex]::Matches($hostName , "(?<=data:\s).+?(?=\s\()")
$ComputerName = $hostNameRegex.value

####### CREATE COLLECTION DIRECTORIES
Write-Host -ForegroundColor Yellow "==============================================================="

$PathExists = Test-Path $dstDrive\Evidence
If ($PathExists -eq $false) {
    mkdir $dstDrive\Evidence | out-null }

$PathExists = Test-Path $dstDrive\Evidence\$ComputerName
If ($PathExists -eq $false) {
    mkdir $dstDrive\Evidence\$ComputerName | out-null }

$PathExists = Test-Path $dstDrive\Evidence\$ComputerName\Modules
If ($PathExists -eq $false) {
    mkdir $dstDrive\Evidence\$ComputerName\Modules | Out-Null }

$PathExists = Test-Path $dstDrive\Evidence\$ComputerName\Targets
If ($PathExists -eq $false) {
    mkdir $dstDrive\Evidence\$ComputerName\Targets | out-null }

Write-Host ""
Write-Host -ForegroundColor Yellow "============ $dstDrive\Evidence\$ComputerName\Targets"
Write-Host -ForegroundColor Yellow "============ $dstDrive\Evidence\$ComputerName\Modules"
Write-Host ""
Write-Host -ForegroundColor Yellow "============ Evidence Collection Folders Created"
Write-Host ""
Write-Host -ForegroundColor Yellow "==============================================================="
Write-Host ""
Start-Sleep -Seconds 2

####### OS DETECTION
Write-Host -ForegroundColor Yellow "============ IRCP detected Hostname as" $ComputerName
Write-Host ""
$os = Get-wmiobject -class win32_operatingsystem
$osInfo = $os.productType
if ($osInfo -eq 1) {
    Write-Host -ForegroundColor Yellow "============ IRCP detected $ComputerName as a Workstation"
    Write-Host ""
}
elseif ($osInfo -eq 2 -Or 3) {
        Write-Host -ForegroundColor Yellow "============ IRCP detected $ComputerName as a Server"
        Write-Host ""
}

####### KAPE EXECUTION
if ($osInfo -eq 1) {
    Write-Host -ForegroundColor Yellow "============ Executing KAPE for Workstation"
    Write-Host ""
    Start-Sleep -Seconds 1
    kape\kape.exe --tsource $srcDrive --tdest $dstDrive\Evidence\$ComputerName\Targets --target $kapeWorkstationTargets --zip $ComputerName --module $kapeModules,RECmd_BasicSystemInfo --mdest $dstDrive\Evidence\$ComputerName\Modules
    }
elseif ($osInfo -eq 2 -Or 3) {
    Write-Host -ForegroundColor Yellow "============ Executing KAPE for Server"
    Write-Host ""
    Start-Sleep -Seconds 1
    kape\kape.exe --tsource $srcDrive --tdest $dstDrive\Evidence\$ComputerName\Targets --target $kapeServerTargets --zip $ComputerName --module $kapeModules,RECmd_BasicSystemInfo --msource --mdest $dstDrive\Evidence\$ComputerName\Modules
    }
else {
    Write-Host -ForegroundColor Yellow "============ Error Please Start Again"
    Write-Host ""
    return
}

####### COLLECTION COMPLETE
Write-Host -ForegroundColor Yellow "== Incident Response Collector Protocol Completed Collection =="
Stop-Transcript | out-null
Move-Item -Path $dstDrive\Evidence\$ComputerName\Modules\Registry\*_BasicSystemInfo_Output.csv $dstDrive\Evidence\$ComputerName\TargetSystemInfo.csv
Move-Item -Path $dstDrive\Evidence\$ComputerName\Modules\*.txt -Destination $dstDrive\Evidence\$ComputerName\kapeModules.log
Move-Item -Path $dstDrive\Evidence\$ComputerName\Targets\*.txt -Destination $dstDrive\Evidence\$ComputerName\kapeTargets.log
Move-Item -Path .\ircpBootableConsole.log -Destination $dstDrive\Evidence\$ComputerName\ircpBootableConsole.log
Pause