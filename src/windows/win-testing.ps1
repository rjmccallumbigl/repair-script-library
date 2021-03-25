# $vms=Get-AzVM
# $vms=Get-AzVM -ResourceGroupName SOURCEVMRG
# $rg="SOURCEVMRG"
foreach ($vm in $vms) {
    # az vm repair create --name $vm.Name --resource-group SOURCEVMRG --repair-username rymccall --repair-password RyanHasaPassword! --verbose --enable-nested
    # az vm repair run -g $rg -n $vm.Name --run-id win-enable-nested-hyperv --run-on-repair --verbose
    az vm repair run -g $rg -n $vm.Name --custom-script-file .\win-toggle-safe-mode.ps1 --verbose --run-on-repair
}
