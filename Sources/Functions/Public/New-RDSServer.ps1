function New-RDSServer {
    <#
.SYNOPSIS
    .
.DESCRIPTION


.PARAMETER Server
    This parameter defines the name of the RDS server that will be created

.PARAMETER IP
    This parameter defines the the IP address of the server to be created.

.PARAMETER VCenter
    This parameter defines the name of the Virtual Center server.

.PARAMETER CustomFile
    This parameter defines the name of the customization file to use.

.PARAMETER TemplateFile
    This parameter defines the name of the template to use.

.PARAMETER Cred
    This parameter defines the credentials for connecting to the virtual center server.

.EXAMPLE
    C:\PS> New-RDSServer -Server SERVER -IP 10.1.1.1 -VCenter SRV-VCenter -TemplateFile MyTemplate -CustomFile MyCustom -cred (get-credential)

    This command will create a server "SERVER" with the IP address "10.1.1.1" based on the template "MyTemplate" and customized by the file "MyCustom"

.NOTES
    Author: LIENHARD Laurent
    Date  : February 28, 2018
#>
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true)][string]$Server,
        [Parameter(Mandatory = $true)][string]$IP,
        [Parameter(Mandatory = $true)][string]$VCenter,
        [Parameter(Mandatory = $true)][string]$CustomFile,
        [Parameter(Mandatory = $true)][string]$TemplateFile,
        [ValidateNotNull()][System.Management.Automation.PSCredential][System.Management.Automation.Credential()][Parameter(Mandatory = $false)]$Cred = [System.Management.Automation.PSCredential]::Empty
    )

    begin {
        Clear-Host

        $ScriptName = (Get-Variable -name MyInvocation -Scope 0 -ValueOnly).Mycommand
        write-verbose "[$Scriptname] - BEGIN PROCESS"

        Import-Module ActiveDirectory -Verbose:$false
        Import-Module -Name VMware.VimAutomation.Core -Verbose:$false
        try {
            Set-PowerCLIConfiguration -Scope Session -InvalidCertificateAction Ignore -Confirm:$false
            if ($global:DefaultVIServer) {
                write-verbose "[$Scriptname] - Connecting to DefaultVIServer "
                Connect-VIServer -Server $global:DefaultVIServer -Session $global:DefaultVIServer.SessionId -Force
            } else {
                write-verbose "[$Scriptname] - Connecting to custom VIServer "
                if (!($Cred)) {
                    $Cred = Get-Credential -Message "Utilisateur avec droit d'admin VI et AD"
                }
                Connect-VIServer -Server $VCenter -Credential $Cred
            }
        } catch {
            Write-Warning "[$Scriptname] - Error connecting to VCenter end of script"
            Break
        }

        write-verbose "[$Scriptname] - Creating VM Object"
        $NewRDS = [RDS]::new($Server, $IP, $TemplateFile, $CustomFile)

        write-verbose "[$Scriptname] - Testing if VMip is free"
        if (!($NewRDS.IsVmIpFree($NewRDS.VMIp))) {
            Write-Error "VmIp is not Free choose another one !" -ErrorAction Stop
        }

        write-verbose "[$Scriptname] - Testing if VMName is free"
        if (!($NewRDS.IsVmNameFree($NewRDS.VMName))) {
            Write-Error "VmName is not Free choose another one !" -ErrorAction Stop
        }
    }

    process {
        $datastore = (Get-Datastore | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1).name
        Write-verbose "[$Scriptname] - The datastore $Datastore will be used..."

        Write-verbose "[$Scriptname] - Creation of the temporary custom file..."
        if (Get-OSCustomizationSpec -Name temp1 -ErrorAction SilentlyContinue) {
            Remove-OSCustomizationSpec -OSCustomizationSpec temp1 -Confirm:$false
        }
        $OSCusSpec = Get-OSCustomizationSpec -Name $CustomFile | New-OSCustomizationSpec -Name 'temp1' -Type NonPersistent

        Write-verbose "[$Scriptname] - Adding the Ip configuration to the temporary custom file..."
        $DefaultGateway = $IP.Replace($IP.Split(".")[-1], 254)
        Get-OSCustomizationSpec $OSCusSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $IP -SubnetMask '255.255.255.0' -DefaultGateway $DefaultGateway -Dns '10.1.50.11', '10.1.50.12'

        $VMTemplate = Get-Template -Name $TemplateFile
        Write-verbose "[$Scriptname] - Using the template $VMtemplate..."

        $VMHost = Get-Cluster | Get-VMHost | Get-Random
        Write-verbose "[$Scriptname] - The host server $VMHost will be used..."

        $DCServer = Get-ADDomainController -Discover -Service "GlobalCatalog"
        #enregion

        #region <Creation de la VM>
        write-verbose "[$Scriptname] - Creating the $Server account in the AD..."
        New-ADComputer -Name $Server -SamAccountName $Server -Path "OU=BUREAU-GIP2,OU=Serveurs RDS,OU=GIP,OU=PHS,DC=netintra,DC=local" -Server $DCServer -Credential $cred
        write-verbose "[$Scriptname] - Adding the $Server server in the AD group for the MSA..."
        Start-Sleep -Second 30
        Add-ADGroupMember -Identity ServeursRDS -Members $Server$

        Write-verbose "[$Scriptname] - Creation of the VM..."
        New-VM -Name $Server -Template $VMTemplate -OSCustomizationSpec $OSCusSpec -VMHost $VMHost -Datastore $datastore -Location "RDSV2"
        Write-verbose "[$Scriptname] - Starting the VM..."
        Start-VM -VM $Server

        Write-Verbose -Message "Verifying that Customization for VM $Server  has started ..."
        while ($True) {
            $DCvmEvents = Get-VIEvent -Entity $Server
            $DCstartedEvent = $DCvmEvents | Where-Object { $_.GetType().Name -eq "CustomizationStartedEvent" }

            if ($DCstartedEvent) {
                break
            }

            else {
                Start-Sleep -Seconds 5
            }
        }

        Write-Verbose -Message "Customization of VM $Server has started. Checking for Completed Status......."
        while ($True) {
            $DCvmEvents = Get-VIEvent -Entity $Server
            $DCSucceededEvent = $DCvmEvents | Where-Object { $_.GetType().Name -eq "CustomizationSucceeded" }
            $DCFailureEvent = $DCvmEvents | Where-Object { $_.GetType().Name -eq "CustomizationFailed" }

            if ($DCFailureEvent) {
                Write-Warning -Message "Customization of VM $Server failed"
                return $False
            }

            if ($DCSucceededEvent) {
                break
            }
            Start-Sleep -Seconds 5
        }
        Write-Verbose -Message "Customization of VM $Server Completed Successfully!"
        Start-Sleep -Seconds 300
        Wait-Tools -VM $Server -TimeoutSeconds 3600
        #endregion


    }

    end {

    }
}