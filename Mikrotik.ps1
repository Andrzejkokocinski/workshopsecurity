#LAB is based on script provided by Chris Polawika - https://blog.polewiak.pl/2017/06/12/mikrotik-w-azure-step-by-step/
#It has been updated and changed as the approach is different. 

#Select-AzureRmContext 

#name of the storage account, in which you have placed the image
$StorageAccountName = "mikrotikvhdimg"
#name of file you have uploaded to storage account
$MikrotikVHD = "chr-6.42.12.vhd"
#name of the container to which you have uploaded the file
$storageContainerName="vhds"
#name of the resource group in which you will create the mikrotik VM
$ResourceGroup = "SecWorkshop"
#location of resources
$Location = "westeurope"
#vnet, in which you will place mikrotik
$VNETName = "vnet01-mng"
#subnet, in which you will place first NIC, which will forward your traffic to Internet
$SubnetName_ether1 = "wfe-subnet"
#subnet, in which you will place second NIC, which will get the traffic from VNET
$SubnetName_ether2 = "backend-subnet"
#name of the Virtual Machine
$VMName = "mikrotikrouter-vm01"
#size of the VM
$VMSize = "Standard_DS1_v2"


$StorageAccount = Get-AzureRmStorageAccount | Where-Object { $_.StorageAccountName -like $StorageAccountName }
$urlOfUploadedVhd = "https://"+$StorageAccountName+".blob.core.windows.net/"+$storageContainerName+"/"+$MikrotikVHD

# Select VNET
$VNET = Get-AzureRmVirtualNetwork -ResourceGroupName $ResourceGroup | Where-Object { $_.Name -like $VNETName }

# Select Subnets
$Subnet_ether1 = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $VNET -Name $SubnetName_ether1
$Subnet_ether2 = Get-AzureRmVirtualNetworkSubnetConfig -VirtualNetwork $VNET -Name $SubnetName_ether2

# Create Public IP
$PublicIP = New-AzureRmPublicIpAddress -ResourceGroupName $ResourceGroup -Location $Location -AllocationMethod Dynamic -IdleTimeoutInMinutes 4 -Name "mt$(Get-Random)"

# Create an inbound network security group rule for port 8291
$nsgRuleRDP = New-AzureRmNetworkSecurityRuleConfig -Name MTManage -Protocol Tcp -Direction Inbound -Priority 1000 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 8291 -Access Allow
# Create an inbound network security group rule for port 80
$nsgRuleWeb = New-AzureRmNetworkSecurityRuleConfig -Name MTWWW -Protocol Tcp -Direction Inbound -Priority 1010 -SourceAddressPrefix * -SourcePortRange * -DestinationAddressPrefix * -DestinationPortRange 80 -Access Allow

# Create a network security group
$nsg = New-AzureRmNetworkSecurityGroup -ResourceGroupName $ResourceGroup -Location $Location -Name Mikrotik_NSG -SecurityRules $nsgRuleRDP,$nsgRuleWeb

# Create a virtual network card and associate with public IP address and NSG
$nic_ether1 = New-AzureRmNetworkInterface -Name ether1 -ResourceGroupName $ResourceGroup -Location $Location -SubnetId $Subnet_ether1.Id -PublicIpAddressId $PublicIP.Id -NetworkSecurityGroupId $nsg.Id -EnableIPForwarding
# Create additional virtual network card
$nic_ether2 = New-AzureRmNetworkInterface -Name ether2 -ResourceGroupName $ResourceGroup -Location $Location -SubnetId $Subnet_ether2.Id -EnableIPForwarding


# Prepare VM Config
$vm = New-AzureRmVMConfig -VMName $VMName -VMSize $VMSize

# Add NIC
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic_ether1.Id -Primary
$vm = Add-AzureRmVMNetworkInterface -VM $vm -Id $nic_ether2.Id

# Attach Disk
$vm = Set-AzureRmVMOSDisk -VM $vm -Name "MT_OS" -VhdUri $urlOfUploadedVhd -Caching ReadWrite -CreateOption Attach -Linux
$vm.OSProfile = $null

# Create the new VM
New-AzureRmVM -ResourceGroupName $ResourceGroup -Location $Location -VM $vm -Verbose
