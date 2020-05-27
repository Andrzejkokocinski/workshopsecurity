$role = Get-AzurermRoleDefinition "Contributor"
$role.Id = $null
$role.Name = "Custome Contributor"
$role.Description = "Can menage Azure Subscription."
#$role.Actions.Clear()
$role.NotActions.Add("Microsoft.Network/*")
$role.Actions.Add("Microsoft.Network/*/read")
$role.Actions.Add("Microsoft.Compute/*/read")
$role.Actions.Add("Microsoft.Compute/virtualMachines/start/action")
$role.Actions.Add("Microsoft.Network/virtualNetworks/BastionHosts/action")
$role.Actions.Add("Microsoft.Network/virtualNetworks/virtualMachines/read")
$role.Actions.Add("Microsoft.Network/virtualNetworks/subnets/joinViaServiceEndpoint/action")
$role.Actions.Add("Microsoft.Network/virtualNetworks/subnets/join/action")
$role.Actions.Add("Microsoft.Network/virtualNetworks/virtualNetworkPeerings/read")
$role.Actions.Add("Microsoft.Network/virtualNetworks/checkIpAddressAvailability/read")
$role.Actions.Add("Microsoft.Network/virtualNetworks/subnets/virtualMachines/read")
$role.Actions.Add("Microsoft.Network/virtualNetworks/checkIpAddressAvailability/read")
$role.Actions.Add("Microsoft.Network/virtualNetworks/bastionHosts/default/action")
$role.Actions.Add("Microsoft.Network/virtualNetworks/subnets/contextualServiceEndpointPolicies/read")
$role.AssignableScopes.Clear()
$role.AssignableScopes.Add("/subscriptions/your subscriptions id")
#$role.AssignableScopes.Add("/subscriptions/11111111-1111-1111-1111-111111111111")
New-AzureRmRoleDefinition -Role $role
