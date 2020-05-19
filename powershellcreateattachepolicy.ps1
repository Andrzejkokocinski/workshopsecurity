# Create the Policy Definition 
$policyrules = "https://raw.githubusercontent.com/Andrzejkokocinski/workshopsecurity/master/policytagmodify.json"
$definition = New-AzPolicyDefinition -Name 'PolicyTags2' -Policy $policyrules -Mode Indexed
 
# Set the scope to a resource group; may also be a resource, subscription, or management group
$scope = Get-AzResourceGroup -Name 'RG01'
 
# Create the Policy Assignment
New-AzPolicyAssignment -Name 'PolicyTags' -DisplayName 'Apply tags and  values' -Scope $scope.ResourceId -PolicyDefinition $definition
