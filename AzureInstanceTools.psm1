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
        Stop-AzureVM -Force -Name $_.Name -ServiceName $_.ServiceName
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

function Invoke-RmtAzure {
Param(
    [string]$vm_username,
    [string]$vm_password,
    [string]$vm_name,
    [string]$azure_service_name,
    [string]$scriptPath,
    [string[]]$ArgumentList)

    write-Host ("Configuring credentials...")
    $winRMCert = (Get-AzureVM -ServiceName $azure_service_name -Name $vm_name | select -ExpandProperty vm).DefaultWinRMCertificateThumbprint
    $azureX509cert = Get-AzureCertificate -ServiceName $azure_service_name -Thumbprint $winRMCert -ThumbprintAlgorithm sha1
    $certTempFile = [IO.Path]::GetTempFileName()
    $azureX509cert.Data | Out-File $certTempFile
    $certToImport = New-Object System.Security.Cryptography.X509Certificates.X509Certificate2 $certTempFile
    $store = New-Object System.Security.Cryptography.X509Certificates.X509Store "Root", "LocalMachine"
    $store.Open([System.Security.Cryptography.X509Certificates.OpenFlags]::ReadWrite)
    $store.Add($certToImport)
    $store.Close()
    Remove-Item $certTempFile

    $uri = Get-AzureWinRMUri -ServiceName $azure_service_name -Name $vm_name
    $secpwd = ConvertTo-SecureString $vm_password -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential($vm_username, $secpwd)
    $sessionopt = New-PSSessionOption -SkipCNCheck -SkipCACheck
    Enable-PSRemoting -Force
    Set-Item wsman:\localhost\client\trustedhosts * -Force
    Restart-Service WinRM

    write-Host "Executing $scriptPath in $vm_name..."
    Invoke-Command `
    -ConnectionUri $uri.ToString() `
    -Credential $credential `
    -SessionOption $sessionopt `
    -FilePath $scriptPath `
    -ArgumentList $ArgumentList
}

Export-ModuleMember -Function Stop-AllAzureInstances, Get-AzureInstancesWithName, Invoke-RmtAzure