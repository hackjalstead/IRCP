<######################################################################

            Incident Response Collection Protocol (IRCP)
                        Multi-Image Version
    ! Edit the Kape parsers below depending on investigational needs!
    ! For multiple Kape parsers use a comma to seperate the values !

#######################################################################>

####################### Kape Targets & Modules ########################

                    $kapeTargets = "!SANS_Triage"
                    $kapeModules = "!EZParser,Chainsaw"

#######################################################################

####### TRANSCRIPT AND TITLE
Start-Transcript .\ircpMultiConsole.log | out-null
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

####### VARIABLE DECLARATION & TARGET DRIVE SELECTION
Write-Host -ForegroundColor Yellow "============ Select the Target Drive"
Write-Host ""
Start-Sleep -Seconds 2
Add-Type -AssemblyName System.Windows.Forms
$browser = New-Object System.Windows.Forms.FolderBrowserDialog
$browser.RootFolder = 'MyComputer'
$browser.Description = "Select the Target Drive"
$null = $browser.ShowDialog()
$targetDrives = $browser.SelectedPath
$Drives = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
$e01Images = Get-ChildItem -Path $targetDrives -include *.e01 -recurse -File
$vmdkImages = Get-ChildItem -Path $targetDrives -include *.vmdk -recurse -File
$vhdImages = Get-ChildItem -Path $targetDrives -include *.vhd -recurse -File
$vhdxImages = Get-ChildItem -Path $targetDrives -include *.vhdx -recurse -File
Write-Host -ForegroundColor Yellow "============ $targetDrives Selected"
Write-Host ""
Start-Sleep -Seconds 1
Write-Host -ForegroundColor Yellow "============ Searching $targetDrives for Images"

####### E01 LOGIC
foreach ($e01 in $e01Images) 
{
    $DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
    $DriveLetter = $null
    Write-Host ""
    Write-Host "Found Image - $($e01.basename)"
    Write-Host ""
    Start-Sleep -Seconds 1
    $PathExists = Test-Path Evidence 
    If ($PathExists -eq $false) { 
            mkdir Evidence | Out-Null }
    Set-Location Evidence
    $PathExists = Test-Path $e01.basename
    If ($PathExists -eq $false) { 
            mkdir $e01.basename | Out-Null }
    $PathExists = Test-Path "$($e01.basename)\Modules"
        If ($PathExists -eq $false) { 
            mkdir "$($e01.basename)\Modules" | Out-Null }
    $PathExists = Test-Path "$($e01.basename)\Targets"
        If ($PathExists -eq $false) { 
            mkdir "$($e01.basename)\Targets" | Out-Null }
    Set-Location ..
    Write-Host -ForegroundColor Yellow "============ Evidence Collection Folders Created"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "============ .\Evidence\$($e01.basename)\Targets"
    Write-Host -ForegroundColor Yellow "============ .\Evidence\$($e01.basename)\Modules"
    Write-Host ""
    Start-Sleep -Seconds 1
if ($e01 -Like "*.e01")
{
    Write-Host -ForegroundColor Yellow "============ Mounting E01 Image"
    Write-Host ""
    .\arsenal\aim_cli.exe /mount /readonly /filename=$e01 /provider=libewf /background
    Start-Sleep -Seconds 5
}
:e01 while($true)
    {
        $DrivesCountNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        if ($DrivesCount -ne $DrivesCountNew) 
        {
            $DrivesNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
            $DriveLetter = Compare-Object -ReferenceObject $Drives -DifferenceObject $DrivesNew | Select-Object -ExpandProperty InputObject | Select-Object -ExpandProperty DeviceId
            if (!($null -eq $DriveLetter))
                { 
                    Write-host "Image mounted as $DriveLetter"
                    foreach ($OSDriveLetter in $DriveLetter) 
                        {
                            if (Test-Path "${OSDriveLetter}\windows\system32") 
                                {
                                    Write-Host "Operating System Drive is ${OSDriveLetter}"
                                    Write-Host "" 
                                }
                        }
                }
            $DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count 
        Write-Host -ForegroundColor Yellow "============ Executing Kape on $OSDriveLetter Drive for $($e01.basename)"
        Write-Host ""
        Kape\kape.exe --ifw --tsource $OSDriveLetter --tdest Evidence\"$($e01.basename)"\Targets --target $kapeTargets --zip target --module $kapeModules,RECmd_BasicSystemInfo --msource Evidence\"$($e01.basename)"\Targets\$drive  --mdest Evidence\"$($e01.basename)"\Modules
        Write-Host -ForegroundColor Yellow "============ Kape Completed on $OSDriveLetter Drive for $($e01.basename)"
        Write-Host ""
        .\arsenal\aim_cli.exe /dismount /force
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ $OSDriveLetter Drive Dismounted"
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ IRCP Completed on $OSDriveLetter Drive for $($e01.basename)"
        Move-Item -Path .\Evidence\$($e01.basename)\Modules\Registry\*_BasicSystemInfo_Output.csv .\Evidence\$($e01.basename)\TargetSystemInfo.csv
        Move-Item -Path .\Evidence\$($e01.basename)\Modules\*.txt -Destination .\Evidence\$($e01.basename)\kapeModules.log
        Move-Item -Path .\Evidence\$($e01.basename)\Targets\*.txt -Destination .\Evidence\$($e01.basename)\kapeTargets.log
        Start-Sleep -Seconds 5
        break
        }            
    }   
} 

####### VMDK LOGIC
foreach ($vmdk in $vmdkImages)  
{
    $DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
    $DriveLetter = $null
    Write-Host ""
    Write-Host "Found Image - $($vmdk.basename)"
    Write-Host ""
    Start-Sleep -Seconds 1
    if ($vmdk -Like "*.vmdk" -And $vmdk.length -lt 3000)
{
        $PathExists = Test-Path Evidence 
        If ($PathExists -eq $false) { 
                mkdir Evidence | Out-Null }
        Set-Location Evidence
        $PathExists = Test-Path $($vmdk.basename)
        If ($PathExists -eq $false) { 
                mkdir $vmdk.basename | Out-Null }
        $PathExists = Test-Path "$($vmdk.basename)\Modules"
            If ($PathExists -eq $false) { 
                mkdir "$($vmdk.basename)\Modules" | Out-Null }
        $PathExists = Test-Path "$($vmdk.basename)\Targets"
            If ($PathExists -eq $false) { 
                mkdir "$($vmdk.basename)\Targets" | Out-Null }
        Set-Location ..
        Start-Sleep -Seconds 2
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ Evidence Collection Folders Created"
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ .\Evidence\$($vmdk.basename)\Targets"
        Write-Host -ForegroundColor Yellow "============ .\Evidence\$($vmdk.basename)\Modules"
        Write-Host ""
        Start-Sleep -Seconds 1
        Write-Host -ForegroundColor Yellow "============ Mounting VMDK Image"
        Write-Host ""
        .\arsenal\aim_cli.exe /mount /readonly /filename=$vmdk /provider=DiscUtils /background
        Start-Sleep -Seconds 5
}
:vmdk while($vmdk -Like "*.vmdk" -And $vmdk.length -lt 3000) 
    {
        $DrivesCountNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        if ($DrivesCount -ne $DrivesCountNew) 
        {
            $DrivesNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
            $DriveLetter = Compare-Object -ReferenceObject $Drives -DifferenceObject $DrivesNew | Select-Object -ExpandProperty InputObject | Select-Object -ExpandProperty DeviceId
            if (!($null -eq $DriveLetter)) 
                {
                    Write-host "Image mounted as $DriveLetter"
                    foreach ($OSDriveLetter in $DriveLetter) 
                    {
                        if (Test-Path "${OSDriveLetter}\windows\system32") 
                            {
                                Write-Host "Operating System Drive is ${OSDriveLetter} Drive"
                                Write-Host "" 
                            }
                    }
                } 
        $DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        Write-Host -ForegroundColor Yellow "============ Executing Kape on $OSDriveLetter Drive for $($vmdk.basename)"
        Write-Host ""
        Kape\kape.exe --ifw --tsource $OSDriveLetter --tdest Evidence\"$($vmdk.basename)"\Targets --target $kapeTargets --zip target --module $kapeModules,RECmd_BasicSystemInfo --msource Evidence\"$($vmdk.basename)"\Targets\$drive  --mdest Evidence\"$($vmdk.basename)"\Modules
        Write-Host -ForegroundColor Yellow "============ Kape Complete on $OSD Drive for $($vmdk.basename)"
        Write-Host ""
        .\arsenal\aim_cli.exe /dismount /force
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ $DriveLetter Dismounted"
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ IRCP Complete on $OSDriveLetter Drive for $($vmdk.basename)"
        Move-Item -Path .\Evidence\$($vmdk.basename)\Modules\*.txt -Destination .\Evidence\$($vmdk.basename)\kapeModules.log
        Move-Item -Path .\Evidence\$($vmdk.basename)\Targets\*.txt -Destination .\Evidence\$($vmdk.basename)\kapeTargets.log
        Move-Item -Path .\Evidence\$($vmdk.basename)\Modules\Registry\*_BasicSystemInfo_Output.csv .\Evidence\$($vmdk.basename)\TargetSystemInfo.csv
        Start-Sleep -Seconds 5
        break
        }
    }
}

####### VHD LOGIC
foreach ($vhd in $vhdImages) 
{
    $DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
    $DriveLetter = $null
    Write-Host ""
    Write-Host "Found Image - $($vhd.basename)"
    Write-Host ""
    Start-Sleep -Seconds 1
    $PathExists = Test-Path Evidence 
    If ($PathExists -eq $false) { 
        mkdir Evidence | Out-Null }
    Set-Location Evidence 
    $PathExists = Test-Path $vhd.basename
    If ($PathExists -eq $false) { 
        mkdir $vhd.basename | Out-Null }
    $PathExists = Test-Path "$($vhd.basename)\Modules"
    If ($PathExists -eq $false) { 
        mkdir "$($vhd.basename)\Modules" | Out-Null}
    $PathExists = Test-Path "$($vhd.basename)\Targets"
        If ($PathExists -eq $false) { 
            mkdir "$($vhd.basename)\Targets" | Out-Null}
    Set-Location ..
    Write-Host -ForegroundColor Yellow "============ Evidence Collection Folders Created"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "============ .\Evidence\$($vhd.basename)\Targets"
    Write-Host -ForegroundColor Yellow "============ .\Evidence\$($vhd.basename)\Modules"
    Write-Host ""
    Start-Sleep -Seconds 1

    if ($vhd -Like "*.vhd") 
{
    Write-Host -ForegroundColor Yellow "============ Mounting VHD Image"
    Write-Host ""
    .\arsenal\aim_cli.exe /mount /readonly /filename=$vhd /provider=DiscUtils /background
}
:vhd while($true) 
    {
        $DrivesCountNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        if ($DrivesCount -ne $DrivesCountNew) 
        {
            $DrivesNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
            $DriveLetter = Compare-Object -ReferenceObject $Drives -DifferenceObject $DrivesNew | Select-Object -ExpandProperty InputObject | Select-Object -ExpandProperty DeviceId
            if (!($null -eq $DriveLetter)) 
                { 
                    Write-host "Image mounted as $DriveLetter"
                    foreach ($OSDriveLetter in $DriveLetter) 
                        {
                            if (Test-Path "${OSDriveLetter}\windows\system32") 
                                {
                                    Write-Host "Operating System Drive is ${OSDriveLetter}"
                                    Write-Host "" 
                                }
                        }
                } 
        $DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        Write-Host -ForegroundColor Yellow "============ Executing Kape on $OSDriveLetter Drive for $($vhd.basename)"
        Write-Host ""
        Kape\kape.exe --ifw --tsource $OSDriveLetter --tdest Evidence\"$($vhd.basename)"\Targets --target $kapeTargets --zip target --module $kapeModules,RECmd_BasicSystemInfo --msource Evidence\"$($vhd.basename)"\Targets\$drive  --mdest Evidence\"$($vhd.basename)"\Modules
        Write-Host -ForegroundColor Yellow "============ Kape Completed on $OSDriveLetter Drive for $($vhd.basename)"
        Write-Host ""
        .\arsenal\aim_cli.exe /dismount /force
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ $OSDriveLetter Drive Dismounted"
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ Kape Complete on $OSDriveLetter Drive for $($vhd.basename)"
        Move-Item -Path .\Evidence\$($vhd.basename)\Modules\Registry\*_BasicSystemInfo_Output.csv .\Evidence\$($vhd.basename)\TargetSystemInfo.csv
        Move-Item -Path .\Evidence\$($vhd.basename)\Modules\*.txt -Destination .\Evidence\$($vhd.basename)\kapeModules.log
        Move-Item -Path .\Evidence\$($vhd.basename)\Targets\*.txt -Destination .\Evidence\$($vhd.basename)\kapeTargets.log
        Start-Sleep -Seconds 5
        break
        }
                    
    }   
} 

####### VHDX LOGIC
foreach ($vhdx in $vhdxImages) 
{
    $DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
    $DriveLetter = $null
    Write-Host ""
    Write-Host "Found Image - $($vhdx.basename)"
    Write-Host ""
    Start-Sleep -Seconds 1
    $PathExists = Test-Path Evidence 
    If ($PathExists -eq $false) { 
        mkdir Evidence | Out-Null }
    Set-Location Evidence 
    $PathExists = Test-Path $($vhdx.basename)
    If ($PathExists -eq $false) { 
        mkdir \$($vhdx.basename) | Out-Null }
    $PathExists = Test-Path "$($vhdx.basename)\Modules" 
    If ($PathExists -eq $false) { 
        mkdir "$($vhdx.basename)\Modules" | Out-Null}
    $PathExists = Test-Path "$($vhdx.basename)\Targets"
        If ($PathExists -eq $false) { 
            mkdir "$($vhdx.basename)\Targets" | Out-Null}
    Set-Location ..
    Write-Host -ForegroundColor Yellow "============ Evidence Collection Folders Created"
    Write-Host ""
    Write-Host -ForegroundColor Yellow "============ .\Evidence\$($vhdx.basename)\Targets"
    Write-Host -ForegroundColor Yellow "============ .\Evidence\$($vhdx.basename)\Modules"
    Write-Host ""
    Start-Sleep -Seconds 1
    if ($vhdx -Like "*.vhdx") 
{
    Write-Host -ForegroundColor Yellow "============ Mounting VHDX Image"
    Write-Host ""
    .\arsenal\aim_cli.exe /mount /readonly /filename=$vhdx /provider=DiscUtils /background
}
:vhdx while($true) 
    {
        $DrivesCountNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        if ($DrivesCount -ne $DrivesCountNew) 
        {
            $DrivesNew = (Get-WmiObject -Query "Select * from Win32_LogicalDisk")
            $DriveLetter = Compare-Object -ReferenceObject $Drives -DifferenceObject $DrivesNew | Select-Object -ExpandProperty InputObject | Select-Object -ExpandProperty DeviceId
            if (!($null -eq $DriveLetter)) 
                { 
                    Write-host "Image mounted as $DriveLetter"
                    foreach ($OSDriveLetter in $DriveLetter) 
                        {
                            if (Test-Path "${OSDriveLetter}\windows\system32") 
                                {
                                    Write-Host "Operating System Drive is ${OSDriveLetter}"
                                    Write-Host "" 
                                }
                        }
                } 
        $DrivesCount = (Get-WmiObject -Query "Select * from Win32_LogicalDisk").Count
        Write-Host -ForegroundColor Yellow "============ Executing Kape on $OSDriveLetter Drive for $($vhdx.basename)"
        Write-Host ""
        Kape\kape.exe --ifw --tsource $OSDriveLetter --tdest Evidence\"$($vhdx.basename)"\Targets --target $kapeTargets --zip target --module $kapeModules,RECmd_BasicSystemInfo --msource Evidence\"$($vhdx.basename)"\Targets\$drive  --mdest Evidence\"$($vhdx.basename)"\Modules
        Write-Host -ForegroundColor Yellow "============ Kape Completed on $OSDriveLetter Drive for $($vhdx.basename)"
        Write-Host ""
        .\arsenal\aim_cli.exe /dismount /force
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ $OSDriveLetter Dismounted"
        Write-Host ""
        Write-Host -ForegroundColor Yellow "============ Kape Complete on $OSDriveLetter Drive for $($vhdx.basename)"
        Move-Item -Path .\Evidence\$($vhdx.basename)\Modules\Registry\*_BasicSystemInfo_Output.csv .\Evidence\$($vhdx.basename)\TargetSystemInfo.csv
        Move-Item -Path .\Evidence\$($vhdx.basename)\Modules\*.txt -Destination .\Evidence\$($vhdx.basename)\kapeModules.log
        Move-Item -Path .\Evidence\$($vhdx.basename)\Targets\*.txt -Destination .\Evidence\$($vhdx.basename)\kapeTargets.log
        Start-Sleep -Seconds 5
        break
        }             
    }   
}
####### TRANSCRIPT AUDIT
Stop-Transcript | Out-Null
Move-Item -Path .\ircpMultiConsole.log -Destination .\Evidence\ircpMultiLabConsole.log
Write-Host -ForegroundColor Yellow "============ Incident Response Collector Protocol Completed Collection ============"
