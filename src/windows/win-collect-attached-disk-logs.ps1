# pip 52.154.77.148



function Get-Disk-Partitions() {
    $partitionlist = $null
    $disklist = get-wmiobject Win32_diskdrive | Where-Object { $_.model -like 'Microsoft Virtual Disk' } 
    ForEach ($disk in $disklist) {
        $diskID = $disk.index
        $command = @"
		select disk $diskID
		online disk noerr
"@
        $command | diskpart | out-null

        $partitionlist += Get-Partition -DiskNumber $diskID
    }
    return $partitionlist
}

try {
    # Declaring variables    
    $desktopFolderPath = "$env:PUBLIC\Desktop\"
    $logFolderName = "CaseLogs"
    $scriptStartTime = get-date
    $scriptStartTimeUTC = ($scriptStartTime).ToUniversalTime() | ForEach-Object { $_ -replace ":", "." } | ForEach-Object { $_ -replace "/", "-" } | ForEach-Object { $_ -replace " ", "_" }
    $collectedLogArray = @()

    # Source: https://github.com/Azure/azure-diskinspect-service/blob/master/pyServer/manifests/windows/windowsupdate
    $logArray = @(
        ### Registry Hives ###    
        '\Windows\System32\config\SOFTWARE'
        '\Windows\System32\config\SYSTEM'
        ### Event Logs ###
        '\Windows\System32\winevt\Logs\System.evtx'
        '\Windows\System32\winevt\Logs\Application.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-ServiceFabric%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-ServiceFabric%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-ServiceFabric-Lease%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-ServiceFabric-Lease%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Windows Azure.evtx'
        ### Additional Event Logs ###
        '\Windows\System32\winevt\Logs\Microsoft-Windows-CAPI2%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Kernel-PnPConfig%4Configuration.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Kernel-PnP%4Configuration.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-NdisImPlatform%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-NetworkLocationWizard%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-NetworkProfile%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-NetworkProvider%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-NlaSvc%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-RemoteDesktopServices-RdpCoreTS%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-RemoteDesktopServices-RemoteDesktopSessionManager%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-RemoteDesktopServices-SessionServices%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Resource-Exhaustion-Detector%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-SmbClient%4Connectivity.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-SMBClient%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-SMBServer%4Connectivity.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-SMBServer%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-ServerManager%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TCPIP%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-LocalSessionManager%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-PnPDevices%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-PnPDevices%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-RDPClient%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-RemoteConnectionManager%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-SessionBroker-Client%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TerminalServices-SessionBroker-Client%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-UserPnp%4DeviceInstall.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Windows Firewall With Advanced Security%4ConnectionSecurity.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Windows Firewall With Advanced Security%4Firewall.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-WindowsUpdateClient%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-WindowsAzure-Diagnostics%4GuestAgent.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-WindowsAzure-Diagnostics%4Heartbeat.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-WindowsAzure-Diagnostics%4Runtime.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-WindowsAzure-Diagnostics%4Bootstrapper.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-WindowsAzure-Status%4GuestAgent.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-WindowsAzure-Status%4Plugins.evtx'
        '\Windows\System32\winevt\Logs\MicrosoftAzureRecoveryServices-Replication.evtx'
        '\Windows\System32\winevt\Logs\Security.evtx'
        '\Windows\System32\winevt\Logs\Setup.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-DSC%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-BitLocker%4BitLocker Management.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-BitLocker-DrivePreparationTool%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Dhcp-Client%4Operational.evtx'
        ### Provisioning ###
        '\AzureData\CustomData.bin'
        '\Windows\Setup\State\State.ini'
        '\Windows\Panther\WaSetup.xml'
        '\Windows\Panther\WaSetup.log'
        '\Windows\Panther\VmAgentInstaller.xml'
        '\Windows\Panther\unattend.xml'
        '\unattend.xml'
        '\Windows\Panther\setupact.log'
        '\Windows\Panther\setuperr.log'
        '\Windows\Panther\UnattendGC\setupact.log'
        '\Windows\Panther\FastCleanup\setupact.log'
        '\Windows\System32\Sysprep\ActionFiles\Generalize.xml'
        '\Windows\System32\Sysprep\ActionFiles\Specialize.xml'
        '\Windows\System32\Sysprep\ActionFiles\Respecialize.xml'
        '\Windows\System32\Sysprep\Panther\setupact.log'
        '\Windows\System32\Sysprep\Panther\IE\setupact.log'
        '\Windows\System32\Sysprep\Panther\setuperr.log'
        '\Windows\System32\Sysprep\Panther\IE\setuperr.log'
        '\Windows\System32\Sysprep\Sysprep_succeeded.tag'
        ### Plug and Play ###
        '\Windows\INF\netcfg*.*etl'
        '\Windows\INF\setupapi.*.log'
        ### Active Directory domain join ###
        '\Windows\debug\netlogon.log'
        '\Windows\debug\NetSetup.LOG'
        '\Windows\debug\mrt.log'
        '\Windows\debug\DCPROMO.LOG'
        '\Windows\debug\dcpromoui.log'
        '\Windows\debug\PASSWD.LOG'
        ### .NET ###
        '\Windows\Microsoft.NET\Framework\v4.0.30319\Config\machine.config'
        '\Windows\Microsoft.NET\Framework64\v4.0.30319\Config\machine.config'
        ### Guest Agent ###
        '\WindowsAzure'
        '\Packages\Plugins'
        '\WindowsAzure\Logs\Telemetry.log'
        '\WindowsAzure\Logs\TransparentInstaller.log'
        '\WindowsAzure\Logs\WaAppAgent.log'
        '\WindowsAzure\config\*.xml'
        '\WindowsAzure\Logs\AggregateStatus\aggregatestatus*.json'
        '\WindowsAzure\Logs\AppAgentRuntime.log'
        '\WindowsAzure\Logs\MonitoringAgent.log'
        '\WindowsAzure\Logs\Plugins\*\*\CommandExecution.log'
        '\WindowsAzure\Logs\Plugins\*\*\Install.log'
        '\WindowsAzure\Logs\Plugins\*\*\Update.log'
        '\WindowsAzure\Logs\Plugins\*\*\Heartbeat.log'
        '\Packages\Plugins\*\*\config.txt'
        '\Packages\Plugins\*\*\HandlerEnvironment.json'
        '\Packages\Plugins\*\*\HandlerManifest.json'
        '\Packages\Plugins\*\*\RuntimeSettings\*.settings'
        '\Packages\Plugins\*\*\Status\*.status'
        '\Packages\Plugins\*\*\Status\HeartBeat.Json'
        '\Packages\Plugins\*\*\PackageInformation.txt'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\*\Configuration\Checkpoint.txt'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\*\Configuration\MaConfig.xml'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\*\Configuration\MonAgentHost.*.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\DiagnosticsPlugin.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\DiagnosticsPluginLauncher.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.RecoveryServices.VMSnapshot\*\IaaSBcdrExtension*.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.Security.IaaSAntimalware\*\AntimalwareConfig.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.Security.Monitoring\*\AsmExtension.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\FabricMSIInstall*.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\InfrastructureManifest.xml'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\TempClusterManifest.xml'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\VCRuntimeInstall*.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Compute.BGInfo\*\BGInfo*.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Compute.JsonADDomainExtension\*\ADDomainExtension.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Compute.VMAccessAgent\*\JsonVMAccessExtension.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.EnterpriseCloud.Monitoring.MicrosoftMonitoringAgent\*\0.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\*\DSCLOG*.json'
        '\WindowsAzure\Logs\Plugins\Microsoft.Powershell.DSC\*\DscExtensionHandler*.log'
        '\WindowsAzure\Logs\Plugins\Symantec.SymantecEndpointProtection\*\sepManagedAzure.txt'
        '\WindowsAzure\Logs\Plugins\TrendMicro.DeepSecurity.TrendMicroDSA\*\*.log'
        '\Packages\Plugins\ESET.FileSecurity\*\agent_version.txt'
        '\Packages\Plugins\ESET.FileSecurity\*\extension_version.txt'
        '\Packages\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\AnalyzerConfigTemplate.xml'
        '\Packages\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\*.config'
        '\Packages\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\Logs\*DiagnosticsPlugin*.log'
        '\Packages\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\schema\wad*.json'
        '\Packages\Plugins\Microsoft.Azure.Diagnostics.IaaSDiagnostics\*\StatusMonitor\ApplicationInsightsPackagesVersion.json'
        '\Packages\Plugins\Microsoft.Azure.RecoveryServices.VMSnapshot\*\SeqNumber.txt'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Microsoft.WindowsAzure.Storage.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\AsmExtensionMonitoringConfig*.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\Extensions\AzureSecurityPack\ASM.Azure.OSBaseline.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\Extensions\AzureSecurityPack\AsmExtensionSecurityPackStartupConfig.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\Extensions\AzureSecurityPack\AsmScan.log'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\Extensions\AzureSecurityPack\AsmScannerConfiguration.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\Extensions\AzureSecurityPack\Azure.Common.scm.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\Extensions\AzureSecurityPack\SecurityPackStartup.log'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\Extensions\AzureSecurityPack\SecurityScanLoggerManifest.man'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\AgentStandardEvents.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\AgentStandardEventsMin.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\AgentStandardExtensions.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\AntiMalwareEvents.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\MonitoringEwsEvents.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\MonitoringEwsEventsCore.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\MonitoringEwsRootEvents.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\MonitoringStandardEvents.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\MonitoringStandardEvents2.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\MonitoringStandardEvents3.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\SecurityStandardEvents.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\SecurityStandardEvents2.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\initconfig\*\Standard\SecurityStandardEvents3.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\Monitoring\agent\MonAgent-Pkg-Manifest.xml'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\MonitoringAgentCertThumbprints.txt'
        '\Packages\Plugins\Microsoft.Azure.Security.Monitoring\*\MonitoringAgentScheduledService.txt'
        '\Packages\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\InstallUtil.InstallLog'
        '\Packages\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\Service\current.config'
        '\Packages\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\Service\InfrastructureManifest.template.xml'
        '\Packages\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\Service\ServiceFabricNodeBootstrapAgent.InstallLog'
        '\Packages\Plugins\Microsoft.Azure.ServiceFabric.ServiceFabricNode\*\Service\ServiceFabricNodeBootstrapAgent.InstallState'
        '\Packages\Plugins\Microsoft.Compute.BGInfo\*\BGInfo.def.xml'
        '\Packages\Plugins\Microsoft.Compute.BGInfo\*\PluginManifest.xml'
        '\Packages\Plugins\Microsoft.Compute.BGInfo\*\config.bgi'
        '\Packages\Plugins\Microsoft.Compute.BGInfo\*\emptyConfig.bgi'
        '\Packages\Plugins\Microsoft.Powershell.DSC\*\DSCWork\*.dsc'
        '\Packages\Plugins\Microsoft.Powershell.DSC\*\DSCWork\*.log'
        '\Packages\Plugins\Microsoft.Powershell.DSC\*\DSCWork\*.dpx'
        '\Packages\Plugins\Microsoft.Powershell.DSC\*\DSCVersion.xml'
        '\Packages\Plugins\Microsoft.Powershell.DSC\*\DSCWork\HotfixInstallInProgress.dsc'
        '\Packages\Plugins\Microsoft.Powershell.DSC\*\DSCWork\PreInstallDone.dsc'
        '\Packages\Plugins\Microsoft.SqlServer.Management.SqlIaaSAgent\*\PackageDefinition.xml'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.NetworkWatcher.Edp.NetworkWatcherAgentWindows\*\*.txt'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.NetworkWatcher.Edp.NetworkWatcherAgentWindows\*\*.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.NetworkWatcher.NetworkWatcherAgentWindows\*\*.txt'
        '\WindowsAzure\Logs\Plugins\Microsoft.Azure.NetworkWatcher.NetworkWatcherAgentWindows\*\*.log'
        '\WindowsAzure\Logs\Plugins\Microsoft.ManagedIdentity.ManagedIdentityExtensionForWindows\*\RuntimeSettings\*.xml'
        '\WindowsAzure\GuestAgent*\CommonAgentConfig.config'
        '\WindowsAzure\Logs\Plugins\Microsoft.Compute.CustomScriptExtension\*\*.log'
        ### Windows Update ###
        '\Windows\Logs\CBS\*.log'
        '\Windows\Logs\CBS\*.cab'
        '\Windows\Logs\DISM\*.log'
        '\Windows\windowsupdate*.log'
        '\Windows\Logs\WindowsUpdate\WindowsUpdate.*.etl'
        '\Windows\Logs\SIH\SIH.*.etl'
        '\Windows\Logs\NetSetup\*.etl'
        '\Windows\WinSxS\pending.xml'
        '\Windows\WinSxS\poqexec.log'
        '\Users\*\AppData\Local\microsoft\windows\windowsupdate.log'
        '\Windows\Logs\dpx\*.log'
        '\Windows\SoftwareDistribution\ReportingEvents.log'
        '\Windows\SoftwareDistribution\DeliveryOptimization\SavedLogs\*.log'
        '\Windows\SoftwareDistribution\DeliveryOptimization\SavedLogs\*.etl'
        '\Windows\SoftwareDistribution\Plugins\7D5F3CBA-03DB-4BE5-B4B36DBED19A6833\TokenRetrieval.log'
        '\Windows\servicing\sessions\sessions.xml'
        '\Windows\Logs\MoSetup\UpdateAgent.log'
        '\Windows\SoftwareDistribution\Download\*\*\*.xml'
        '\Windows\SoftwareDistribution\Download\*\*\*.log'
        '\ProgramData\UsoPrivate\UpdateStore\*.xml'
        '\ProgramData\USOShared\Logs\*.etl'
        '\Users\*\AppData\Local\Temp\winstore.log'
        '\Users\*\AppData\Local\Packages\WinStore_cw5n1h2txyewy\AC\Temp\winstore.log'
        '\Windows\SoftwareDistribution\datastore\DataStore.edb'
        '\WindowsUpdateVerbose.etl'
        '\Windows\ServiceProfiles\NetworkService\AppData\Local\Microsoft\Windows\DeliveryOptimization\Logs\*.etl'
        '\Windows\ServiceProfiles\LocalService\AppData\Local\Microsoft\WSLicense\tokens.dat'
        '\Windows\SoftwareDistribution\Plugins\7D5F3CBA-03DB-4BE5-B4B36DBED19A6833\117CAB2D-82B1-4B5A-A08C-4D62DBEE7782.cache'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-WindowsUpdateClient%%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-TaskScheduler%%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Bits-Client%%4Operational.evtx'
        '\Windows\System32\Winevt\Logs\*AppX*.evtx'
        '\Windows\System32\Winevt\Logs\Microsoft-WS-Licensing%%4Admin.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Kernel-PnP%%4Configuration.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-Store%%4Operational.evtx'
        '\Windows\System32\winevt\Logs\Microsoft-Windows-DeliveryOptimization%%4Operational.evtx'
        ### Windows Update - in-place upgrade ###
        '\Windows\Panther\miglog.xml'
        '\Windows\Logs\mosetup\bluebox.log'
        '\$Windows.~BT\Sources\Panther\setupact.log'
        '\$Windows.~BT\Sources\Panther\setuperr.log'
        '\$Windows.~BT\Sources\Panther\miglog.xml'
        '\Windows\Logs\SetupCleanupTask\setupact.log'
        '\Windows\Logs\SetupCleanupTask\setuperr.log'
        '\Windows.old\Windows\Logs\mosetup\bluebox.log'
        '\Windows.old\Windows\Logs\WindowsUpdate\*.etl'
        '\Windows.old\Windows\SoftwareDistribution\ReportingEvents.log'
        '\Windows.old\ProgramData\USOPrivate\UpdateStore'
        '\Windows.old\ProgramData\USOShared\Logs'
        ### Azure Site Recovery (ASR) ###
        '\ProgramData\ASRSetupLogs\UnifiedAgentMSIInstall.log'
        '\ProgramData\ASRSetupLogs\WrapperUnifiedAgent.log'
        '\ProgramData\ASRSetupLogs\ASRUnifiedAgentInstaller.log'
        '\ProgramData\ASRSetupLogs\ASRUnifiedAgentConfigurator.log'
        '\Program Files (x86)\Microsoft Azure Site Recovery\agent\AzureRcmCli.log'
        '\Program Files (x86)\Microsoft Azure Site Recovery\agent\svagents*.log'
        '\Program Files (x86)\Microsoft Azure Site Recovery\agent\s2*.log'
        '\Program Files (x86)\Microsoft Azure Site Recovery\agent\evtcollforw*.log'
        ### Windows Firewall ###
        '\Windows\System32\LogFiles\Firewall\pfirewall.log'
        '\Windows\System32\LogFiles\Firewall\pfirewall.log.old'
        '\Windows\Logs\waasmedic\waasmedic.*.etl'
        ### System Restore ###
        '\Windows\Logs\SystemRestore\*.*'
        ### Windows Minidump ###
        '\Windows\Minidump\*.dmp'
        '\Windows\*.DMP'
    )

    # Make sure the disk is online
    Write-Host "#02 - Bringing disk online"
    $disk = get-disk -ErrorAction Stop | Where-Object { $_.FriendlyName -eq 'Msft Virtual Disk' }
    $disk | set-disk -IsOffline $false -ErrorAction Stop
 
    # Handle disk partitions
    $partitionlist = Get-Disk-Partitions
    $partitionGroup = $partitionlist | Group-Object DiskNumber

    Write-Host '#03 - enumerate partitions for boot config'

    forEach ( $partitionGroup in $partitionlist | Group-Object DiskNumber ) {
        # Reset paths for each part group (disk)
        $isBcdPath = $false
        $bcdPath = ''
        $isOsPath = $false
        $osPath = ''

        # Scan all partitions of a disk for bcd store and os file location 
        ForEach ($drive in $partitionGroup.Group | Select-Object -ExpandProperty DriveLetter ) {      
            # Check if no bcd store was found on the previous partition already
            if ( -not $isBcdPath ) {
                $bcdPath = $drive + ':\boot\bcd'
                $isBcdPath = Test-Path $bcdPath

                # If no bcd was found yet at the default location look for the uefi location too
                if ( -not $isBcdPath ) {
                    $bcdPath = $drive + ':\efi\microsoft\boot\bcd'
                    $isBcdPath = Test-Path $bcdPath
                } 
            }        

            # Check if os loader was found on the previous partition already
            if (-not $isOsPath) {
                $osPath = $drive + ':\windows\system32\winload.exe'
                $isOsPath = Test-Path $osPath
            }
        }
    
        # Create or get CaseLogs folder on desktop
        if (Test-Path "$($desktopFolderPath)$($logFolderName)") {
            $folder = Get-Item -Path "$($desktopFolderPath)$($logFolderName)"
            Write-Host "Grabbing folder $($folder)"
        }
        else {
            $folder = New-Item -Path $desktopFolderPath -Name $logFolderName -ItemType "directory"
            Write-Host "Creating folder $($folder)"
        }

        # Create subfolder named after the current time in UTC
        $subFolder = New-Item -Path $folder.ToString() -Name "$($scriptStartTimeUTC)_UTC" -ItemType "directory"

        # Create log files indicating files successfully and unsuccessfully grabbed by script
        $logFile = "$subfolder\collectedLogFiles.log"
        $failedLogFile = "$subfolder\failedLogFiles.log"

        # If Boot partition found grab bcd store and root partition log files
        if ( $isBcdPath ) {
            # Copy $bcdPath            
            $bcdParentFolderName = $bcdPath.Split("\")[-2]
            $bcdFileName = $bcdPath.Split("\")[-1]

            if (Test-Path "$($subFolder.ToString())\$($bcdParentFolderName)") {
                $folder = Get-Item -Path "$($subFolder.ToString())\$($bcdParentFolderName)"
            }
            else {
                $folder = New-Item -Path $subFolder -Name $bcdParentFolderName -ItemType "directory"
            }

            Write-Host "Copy bootloader $($bcdPath) to $($subFolder.ToString())"
            Copy-Item -Path $bcdPath -Destination "$($folder)\$($bcdFileName)" -Recurse
            $bcdPath | out-file -FilePath $logFile -Append
        }
        else {
            Write-Host "Cannot grab bootloader, make sure disk is attached and partition is online"
        }
    
        # If Windows partition found grab log files
        if ( $isOsPath ) {

            # Go through each log in our array
            foreach ($logName in $logArray) {
                $logLocation = "$($drive):$($logName)"; 

                # Confirm file exists
                if (Test-Path $logLocation) {                    
                    $itemToCopy = Get-ChildItem $logLocation -Force                    
                    foreach ($collectedLog in $itemToCopy) {
                        $collectedLogArray += $collectedLog.FullName
                    }                                                 
                }
                else {
                    "NOT FOUND: $($logLocation)" | out-file -FilePath $failedLogFile -Append
                }
            }            

            # Copy verified logs to subfolder on Rescue VM desktop
            $collectedLogArray | ForEach-Object {
                Write-Host "Copy log $($_)"
        
                $split = $_ -split '\\'
                $DestFile = $split[1..($split.Length - 1)] -join '\' 
                $DestFile = "$subFolder\$DestFile"
                    
                # Confirm if current log is a file or folder        
                if (Test-Path -Path $_ -PathType Leaf) {
                    $logType = "File";
                    $temp = New-Item -Path $DestFile -Type $logType -Force
                    Copy-Item -Path $_ -Destination $DestFile -Force

                }
                elseif (Test-Path -Path $_ -PathType Container) {
                    $logType = "Directory";
                    Copy-Item -Path $_ -Destination $DestFile -Force -Recurse
                }           
                $_ | out-file -FilePath $logFile -Append
            }


        }   
        else {
            Write-Host "Can't grab OS logs, make sure disk is attached and partition is online"
        }
    }

    # Zip files
    Write-Host "Creating zipped archive $($subFolder.Name).zip"
    $compress = @{
        Path             = $subFolder
        CompressionLevel = "Fastest"
        DestinationPath  = "$($desktopFolderPath)\$($subFolder.Name).zip"
    }
    Compress-Archive @compress
}
catch {
    Write-Host "Failed on $($logLocation)"   

    # Zip files
    Write-Host "Creating zipped archive anyways: $($subFolder.Name).zip"
    $compress = @{
        Path             = $subFolder
        CompressionLevel = "Fastest"
        DestinationPath  = "$($desktopFolderPath)\$($subFolder.Name).zip"
    }
    Compress-Archive @compress

    throw $_ 
}