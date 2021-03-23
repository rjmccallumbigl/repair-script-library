<# 

Fixes certain boot errors with WINLOAD.EXE or \BOOT\BCD

https://docs.microsoft.com/en-US/troubleshoot/azure/virtual-machines/boot-error-0xc0000034

Run the following command line as an administrator, and then record the identifier of Windows Boot Loader (not Windows Boot Manager). The identifier is a 32-character code and it looks like this: xxxxxxxx-xxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx. You will use this identifier in the next step.

Console

Copy
bcdedit /store **<Boot partition>** :\boot\bcd /enum
Repair the Boot Configuration data by running the following command lines. You must replace these placeholders by the actual values:

<Windows partition> is the partition that contains a folder named "Windows."
<Boot partition> is the partition that contains a hidden system folder named "Boot."
<Identifier> is the identifier of Windows Boot Loader you found in the previous step.
Console

Copy
bcdedit /store <Boot partition>:\boot\bcd /create {bootmgr}

bcdedit /store <Boot partition>:\boot\bcd /set {bootmgr} description "Windows Boot Manager"

bcdedit /store <Boot partition>:\boot\bcd /set {bootmgr} locale en-us

bcdedit /store <Boot partition>:\boot\bcd /set {bootmgr} inherit {globalsettings}

bcdedit /store <Boot partition>:\boot\bcd /set {bootmgr} displayorder <Identifier>

bcdedit /store <Boot partition>:\boot\bcd /set {bootmgr} timeout 30
Detach the repaired OS disk from the troubleshooting VM. Then, create a new VM from the OS disk.

Gather the current booting setup info and document it on the case. We will use this step to take note of the identifier on the active partition:
For Generation 1 VM:


    bcdedit /store <drive letter>:\boot\bcd /enum
If this errors out because there's no \boot\bcd file, then go to the following mitigation
Write down the identifier of the Windows Boot loader: This is the one which path is \windows\system32\winload.exe:
BCD-Windows-Identifier.png
For Generation 2 VM:


    bcdedit /store <Volume Letter of EFI System Partition>:EFI\Microsoft\boot\bcd /enum
If this errors out because there's no \boot\bcd file, then go to the following mitigation
Write down the identifier of the Windows Boot loader: This is the one which path is \windows\system32\winload.efi:
BCD-Windows-IdentifierGen2-1.png
Step 3

Then run the following commands:
For Generation 1 VM:


    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} device partition=<BCD FOLDER - DRIVE LETTER>:
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} integrityservices enable
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} device partition=<WINDOWS FOLDER - DRIVE LETTER>:
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} integrityservices enable
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} recoveryenabled Off
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} osdevice partition=<WINDOWS FOLDER - DRIVE LETTER>:
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} bootstatuspolicy IgnoreAllFailures
Note: In case the VHD has a single partition and both the BCD Folder and Windows Folder are in the same volume and if the above setup didn't work, then try replacing the partition values with boot


    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} device boot
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} integrityservices enable
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} device boot
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} integrityservices enable
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} recoveryenabled Off
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} osdevice boot
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} bootstatuspolicy IgnoreAllFailures
For Generation 2 VM:


    bcdedit /store <Volume Letter of EFI System Partition>:EFI\Microsoft\boot\bcd /set {bootmgr} device partition=<Volume Letter of EFI System Partition>:
    bcdedit /store <Volume Letter of EFI System Partition>:EFI\Microsoft\boot\bcd /set {bootmgr} integrityservices enable
    bcdedit /store <Volume Letter of EFI System Partition>:EFI\Microsoft\boot\bcd /set {<IDENTIFIER>} device partition=<WINDOWS FOLDER - DRIVE LETTER>:
    bcdedit /store <Volume Letter of EFI System Partition>:EFI\Microsoft\boot\bcd /set {<IDENTIFIER>} integrityservices enable
    bcdedit /store <Volume Letter of EFI System Partition>:EFI\Microsoft\boot\bcd /set {<IDENTIFIER>} recoveryenabled Off
    bcdedit /store <Volume Letter of EFI System Partition>:EFI\Microsoft\boot\bcd /set {<IDENTIFIER>} osdevice partition=<WINDOWS FOLDER - DRIVE LETTER>:
    bcdedit /store <Volume Letter of EFI System Partition>:EFI\Microsoft\boot\bcd /set {<IDENTIFIER>} bootstatuspolicy IgnoreAllFailures

Gen 1: 
REM Create a copy of the BuiltIn BCD template that comes within each windows installation. In this case as the OS is Gen 1, use the BIOS flag
    bcdboot <WINDOWS FOLDER - DRIVE LETTER>:\windows /s <BCD FOLDER - DRIVE LETTER>: /v /f BIOS
        
    REM Re-add the following flags which are not going to be there by default:
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER FROM THE BOOT LOADER>} integrityservices enable
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER FROM THE BOOT LOADER>} recoveryenabled Off
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER FROM THE BOOT LOADER>} bootstatuspolicy IgnoreAllFailures 
        
    REM Renable EMS to enable the serial console feature
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} displaybootmenu yes
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} timeout 5
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} bootems yes
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /ems {current} on 
    bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /emssettings EMSPORT:1 EMSBAUDRATE:115200

Gen 2:
   REM Create a copy of the BuiltIn BCD template that comes within each windows installation. In this case as the OS is Gen 1, use the UEFI flag
   bcdboot <WINDOWS FOLDER - DRIVE LETTER>:\windows /s <Volume Letter of EFI System Partition>: /v /f UEFI
       
   REM Re-add the following flags which are not going to be there by default:
   bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} integrityservices enable
   bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} recoveryenabled Off
   bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {<IDENTIFIER>} bootstatuspolicy IgnoreAllFailures
       
  REM Renable EMS to enable the serial console feature
   bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} displaybootmenu yes
   bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} timeout 5
   bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /set {bootmgr} bootems yes
   bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /ems {current} on 
   bcdedit /store <BCD FOLDER - DRIVE LETTER>:\boot\bcd /emssettings EMSPORT:1 EMSBAUDRATE:115200

#>