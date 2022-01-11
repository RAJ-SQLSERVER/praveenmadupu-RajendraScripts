$instanceName = 'MSSQLSERVER' #Specify the instance name. For default instance, use MSSQLSERVER.
$computerName = $env:COMPUTERNAME
$smo = 'Microsoft.SqlServer.Management.Smo.'
$wmi = New-Object ($smo + 'Wmi.ManagedComputer')

# For the named instance, on the current computer, for the TCP protocol,
# loop through all the IPs and configure them to use the standard port
# of 1433.
$uri = "ManagedComputer[@Name='$computerName']/ ServerInstance[@Name='$instanceName']/ServerProtocol[@Name='Tcp']"
$Tcp = $wmi.GetSmoObject($uri)
foreach ($ipAddress in $Tcp.IPAddresses)
{
    $ipAddress.IPAddressProperties["TcpDynamicPorts"].Value = ""
    $ipAddress.IPAddressProperties["TcpPort"].Value = "1222"  #Specify the SQL port number to set 
}
$Tcp.Alter()

# Restart the SQL instance of SQL Server to enable the changes.
$svc=Get-Service
$i
$i=1
foreach($service in $svc)
{
if ($svc[$i].name -eq "MSSQLSERVER" -or
    $svc[$i].name -eq "SQLSERVERAGENT" -or
    $svc[$i].name -eq "MSSQLFDLauncher" -or
    $svc[$i].name -eq "SQLServerReportingServices" -or
    $svc[$i].name -eq "MsDtsServer150" -or
    $svc[$i].name -eq "SQLTELEMETRY" -or
    $svc[$i].name -eq "SSISTELEMETRY150" -or
    $svc[$i].name -eq "SQLWriter")
    {
        if($svc[$i].status -eq "Stopped")
        {
            start-service -name $svc[$i].Name -PassThru
        }
        if($svc[$i].status -eq "Running")
        {    
            stop-service -name $svc[$i].Name -Force -PassThru
        }
        }
$i++
}
Write-Output " "
Write-Output "SQL Services Successfully Restarted."