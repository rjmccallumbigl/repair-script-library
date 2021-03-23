<# 

Fixes BOOTMGR is missing Press Ctrl+Alt+Del to restart


Verify the OS partition which holds the BCD store for the disk is marked as active
Open an elevated command prompt and open up DISKPART tool
diskpart
List the disks on the system and look for added disks and proceed to select the new disk. In this example, this is Disk 1
list disk
sel disk 1
Diskpart-1.png
List all the partitions on that disk and then proceed to select the partition you want to check. Usually System Managed partitions are smaller and are around 350Mb big. In the image below, this will be Partition 1
list partition
sel partition 1
Diskpart-2.png
Check the status of the partition. The same should be Active
detail partition
Diskpart-3.png
If the partition is 'not active then
Now change the Active flag and then recheck the change was done properly.
active
detail partition
Diskpart-4.png
Now exist DISKPART tool
exit


#>