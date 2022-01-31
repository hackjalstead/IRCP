<######################################################################

            Incident Response Collection Protocol (IRCP)
                        Single-Image Version
    ! Edit the KAPE parsers below depending on investigational needs!
    ! For multiple KAPE parsers use a comma to seperate the values !

#######################################################################>

####################### KAPE Targets & Modules ########################

                $kapeWorkstationTargets = "!SANS_Triage"
                $kapeServerTargets = "!SANS_Triage,ServerTriage"
                $kapeModules = "!EZParser"

#######################################################################

####### TRANSCRIPT AND TITLE
Start-Transcript .\ircpSingleConsole.log | out-null
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

####### SELECT FORENSIC IMAGE
Write-Host -ForegroundColor Yellow "============ Select Image Location to Mount"
Write-Host ""
Start-Sleep -Seconds 2
Add-Type -AssemblyName System.Windows.Forms
$FileBrowser = New-Object System.Windows.Forms.OpenFileDialog
$FileBrowser.filter = "All Files (*.*)|*.*|Forensic Images (*.e01)|*.e01|Virtual HDX (*.vhdx)|*.vhdx|Virtual HD (*.vhd)|*.vhd|VMDK (*.vmdk)|*.vmdk"
[void]$FileBrowser.ShowDialog()
$image = $FileBrowser.FileName
$extension = [IO.Path]::GetExtension($image)
$imagefilename = [System.IO.Path]::GetFileName($image)
$DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
$Drives = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
Write-Host -ForegroundColor Yellow $FileBrowser.FileName
Write-Host ""
Start-Sleep -Seconds 2

####### IMAGE TYPE LOGIC
if ($extension -Like "*.e01") {
    Write-Host -ForegroundColor Yellow "============ Mounting E01 Image"
    Write-Host ""
    .\arsenal\aim_cli.exe /mount /readonly /filename=$image /provider=libewf /background
    Start-Sleep -Seconds 5
:e01 while($true) {
    $DrivesCountNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        if ($DrivesCount -ne $DrivesCountNew)
          {
          $DrivesNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
          $DriveLetters = Compare-Object -ReferenceObject $Drives -DifferenceObject $DrivesNew | Select-Object -ExpandProperty InputObject | Select-Object -ExpandProperty DeviceId
                  if (!($null -eq $DriveLetters)) {
                  Write-host "New drives mounted $DriveLetters"
                foreach ($DriveLetter in $DriveLetters) {
                    if (Test-Path "${DriveLetter}\windows\system32") {
                        Write-Host "Operating System Drive is ${DriveLetter}" } }
                        Write-Host ""
                    Write-Host -ForegroundColor Yellow "============ E01 Mount Successful" } break } }
} elseif ($extension -Like "*.vhdx") {
    Write-Host -ForegroundColor Yellow "============ Mounting VHDX Image"
    Write-Host ""
    .\arsenal\aim_cli.exe /mount /readonly /filename=$image /provider=DiscUtils /background
    Start-Sleep -Seconds 5
:vhdx while($true) {
    $DrivesCountNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        if ($DrivesCount -ne $DrivesCountNew)
          {
          $DrivesNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
          $DriveLetters = Compare-Object -ReferenceObject $Drives -DifferenceObject $DrivesNew | Select-Object -ExpandProperty InputObject | Select-Object -ExpandProperty DeviceId
                if (!($null -eq $DriveLetters)) {
                  Write-host "New drives mounted $DriveLetters"
                foreach ($DriveLetter in $DriveLetters) {
                    if (Test-Path "${DriveLetter}\windows\system32") {
                        Write-Host "Operating System Drive is ${DriveLetter}" } }
                        Write-Host ""
                    Write-Host -ForegroundColor Yellow "============ VHDX Mount Successful" } break } }
} elseif ($extension -Like "*.vhd") {
    Write-Host -ForegroundColor Yellow "============ Mounting VHD Image"
    Write-Host ""
    .\arsenal\aim_cli.exe /mount /readonly /filename=$image /provider=DiscUtils /background
    Start-Sleep -Seconds 5
:vhd while($true) {
    $DrivesCountNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        if ($DrivesCount -ne $DrivesCountNew)
          {
          $DrivesNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
          $DriveLetters = Compare-Object -ReferenceObject $Drives -DifferenceObject $DrivesNew | Select-Object -ExpandProperty InputObject | Select-Object -ExpandProperty DeviceId
                if (!($null -eq $DriveLetters)) {
                  Write-host "New drives mounted $DriveLetters"
                foreach ($DriveLetter in $DriveLetters) {
                    if (Test-Path "${DriveLetter}\windows\system32") {
                        Write-Host "Operating System Drive is ${DriveLetter}" } }
                        Write-Host ""
                    Write-Host -ForegroundColor Yellow "============ VHD Mount Successful" } break } }
} elseif ($extension -Like "*.vmdk") {
    Write-Host -ForegroundColor Yellow "============ Mounting VMDK Image"
    Write-Host ""
    .\arsenal\aim_cli.exe /mount /readonly /filename=$image /provider=DiscUtils /background
    Start-Sleep -Seconds 5
:vmdk while($true) {
    $DrivesCountNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        if ($DrivesCount -ne $DrivesCountNew)
          {
          $DrivesNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
          $DriveLetters = Compare-Object -ReferenceObject $Drives -DifferenceObject $DrivesNew | Select-Object -ExpandProperty InputObject | Select-Object -ExpandProperty DeviceId
                if (!($null -eq $DriveLetters)) {
                  Write-host "New drives mounted $DriveLetters"
                foreach ($DriveLetter in $DriveLetters) {
                    if (Test-Path "${DriveLetter}\windows\system32") {
                        Write-Host "Operating System Drive is ${DriveLetter}" } }
                        Write-Host ""
                Write-Host -ForegroundColor Yellow "============ VMDK Mount Successful" } break } } }
Start-Sleep -Seconds 2

####### PRESENT COLLECTION MENU
function Show-Menu
{
    param (
        [string]$Title = 'Incident Response Collection Protocol'
    )
    Write-Host ""
    Write-Host -ForegroundColor Yellow "============ Collection Menu"
    Write-Host ""
    Write-Host "     1: Press '1' for Workstation - Windows XP-11"
    Write-Host "     2: Press '2' for Server   - DC, Exchange, Generic Windows, IIS, Apache, NGINX, MYSQL, ManageEngine, Confluence, FileZilla, OpenSSH"
    Write-Host "     Q: Press 'Q' to Quit and Dismount"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "================================"
}
Start-Sleep -Seconds 2

####### TAKE COLLECTION MENU INPUT
Show-Menu -Title 'Incident Response Collection Protocol'
Write-Host ""
 $selection = Read-Host "     Please make a selection"
 switch ($selection)
 {
       '1' {
         '     You chose - Workstation'
                Write-Host ""
     } '2' {
         '     You chose - Server'
                Write-Host ""
     } 'q' {
        .\arsenal\aim_cli.exe /dismount /force
         return
     }
 }
Start-Sleep -Seconds 2

####### EVIDENCE FOLDER CREATION
$PathExists = Test-Path Evidence
    If ($PathExists -eq $false) {
            mkdir Evidence | Out-Null }
    Set-Location Evidence
    $PathExists = Test-Path $imagefilename
    If ($PathExists -eq $false) {
            mkdir $imagefilename | Out-Null }
    $PathExists = Test-Path $imagefilename\Modules
        If ($PathExists -eq $false) {
            mkdir $imagefilename\Modules | Out-Null }
    $PathExists = Test-Path $imagefilename\Targets
        If ($PathExists -eq $false) {
            mkdir $imagefilename\Targets | Out-Null }
    Set-Location ..
    Write-Host -ForegroundColor Yellow "============ Evidence Collection Folders Created"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "============ .\Evidence\$imagefilename\Targets"
    Write-Host -ForegroundColor Yellow "============ .\Evidence\$imagefilename\Modules"
    Write-Host ""
    Start-Sleep -Seconds 2

####### KAPE Execution
if ($selection -eq "1" -And $DriveLetter -match '[a-z]') {
    Write-Host -ForegroundColor Yellow "============ Executing KAPE for Workstation on $DriveLetter Drive"
    Write-Host ""
    KAPE\kape.exe --ifw --tsource $DriveLetter --tdest Evidence\$imagefilename\Targets --target $kapeWorkstationTargets --zip target --module $kapeModules,RECmd_BasicSystemInfo --msource Evidence\$imagefilename\Targets\$drive  --mdest Evidence\$imagefilename\Modules
    }
elseif ($selection -eq "2" -And $DriveLetter -match '[a-z]') {
    Write-Host -ForegroundColor Yellow "============ Executing KAPE for Server on $DriveLetter Drive"
    Write-Host ""
    KAPE\kape.exe --ifw --tsource $DriveLetter --tdest Evidence\$imagefilename\Targets --target $kapeServerTargets --zip target --module $kapeModules,RECmd_BasicSystemInfo --msource Evidence\$imagefilename\Targets\$drive --mdest Evidence\$imagefilename\Modules
    }
else {
    Write-Host -ForegroundColor Yellow "============ Error Please Start Again"
Exit
    }

####### Y TERMINADO
Write-Host -ForegroundColor Yellow "============ KAPE Complete - Dismounting Image"
Write-Host ""
.\arsenal\aim_cli.exe /dismount /force
Write-Host ""
Write-Host -ForegroundColor Yellow "============ Incident Response Collector Protocol Completed Collection ============"
Write-Host ""
Stop-Transcript | out-null
Move-Item -Path .\Evidence\$imagefilename\Modules\Registry\*_BasicSystemInfo_Output.csv .\Evidence\$imagefilename\TargetSystemInfo.csv
Move-Item -Path .\Evidence\$imagefilename\Modules\*.txt -Destination .\Evidence\$imagefilename\kapeModules.log
Move-Item -Path .\Evidence\$imagefilename\Targets\*.txt -Destination .\Evidence\$imagefilename\kapeTargets.log
Move-Item -Path .\ircpSingleConsole.log -Destination .\Evidence\$imagefilename\ircpSingleConsole.log
Pause