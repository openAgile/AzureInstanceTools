function Stop-AllAzureInstances {
param(
    $exclude
    )
    $instances = $null
    if($exclude -eq $null) {
       $instances = Get-AzureVM
    } else {
        $instances = Get-AzureInstancesWithName "*" -exclude $exclude
    }
    $instances | `
    % { 
        Write-Host "Stopping $($_.name)" 
        Stop-AzureVM -StayProvisioned -Force -Name $_.Name -ServiceName $_.ServiceName
    }
}

function Get-AzureInstancesWithName {
param(
[parameter(Mandatory=$true,Position=0)]$name,
[parameter(Mandatory=$false,Position=1)]$exclude)
    $instances = Get-AzureVM | ? { $_.Name -Like $name}
    if($exclude -ne $null) {
        $instances = $instances | ? {
            $name = $_.Name
            $shouldPass = $true
            $exclude | % { $shouldPass = ($shouldPass -and $name -notlike $_)}
            $shouldPass
        }
    }
    $instances
}

Export-ModuleMember -Function Stop-AllAzureInstances, Get-AzureInstancesWithName