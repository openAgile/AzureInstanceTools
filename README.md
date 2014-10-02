## AzureInstanceTools ##

Azure Instance Tools lets you simplify using the [Azure PowerShell](http://msdn.microsoft.com/en-us/library/azure/jj156055.aspx) to start and stop your Azure virtual machines.

# Requirements

Instructions on [How to install and configure Azure PowerShell](http://azure.microsoft.com/en-us/documentation/articles/install-configure-powershell/)

# Test installation

Once you have everything installed and your credentials set, try the example commands below.

# Basic usage

To test that you are configured correctly, run this command:

```powershell
Get-AzureInstancesWithName "*"
```

Expect something like this as a result:

```
PS C:\Windows\system32> Get-AzureInstancesWithName "*"

ServiceName                             Name                                    Status
-----------                             ----                                    ------
Jira-6                                  Jira-6                                  StoppedDeallocated
ServiceTFS2013                          VmTFS2013                               StoppedVM
sqlSandbox01                            sqlSandbox01                            ReadyRole
v1commitstream                          v1commitstream                          StoppedVM
WEventStore                             WEventStore                             StoppedVM
```


# Get several instances
We can get one or more instances by passing a filter. This filters by the name:

```powershell
Get-AzureInstancesWithName "sql*"
```

The previous example gets all the instances with the name that starts with "sql". The filter is case insensitive.

# Stopping all instances
If you want to stop all running instances, but not terminate them, then do this:

```powershell
Stop-AllAzureInstances
```

# Stopping several instances with an exclution filter
Stops the instances, excluding the instances that do not match any of the filters.

```powershell
Stop-AllAzureInstances -exclude @("sql*", "jira*")
```

This execution will stop every VM that do not start with "sql" or "jira".