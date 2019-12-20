Class VM {
    [System.String]$VMName
    [System.String]$VMIp
    [System.String]$VMType
    HIDDEN [System.String]$Datastore
    HIDDEN [System.String]$VMHost
    HIDDEN [System.String]$VMTemplate
    HIDDEN $OSCusSpec

    #region <Constructor>
    VM () {
    }

    VM ([System.String]$VMName, [System.String]$VMIp) {
        $this.VMName = $VMName.ToUpper()
        $this.VMIp = $VMIp
        $this.VMType = "VM"
    }
    #endregion

    #region <Method>

    #region <test Ip and VmName>
    [System.Boolean] IsVmIpFree ([System.String]$VMIp) {
        $Ping = New-Object System.Net.Networkinformation.ping
        $Status = ($Ping.Send("$VMIP", 1)).Status
        if ($Status -eq "Success") {
            #$VMIP is in use!"
            return $false
        } else {
            #$VMIP is free!"
            return $true
        }
    }

    [System.Boolean] IsVmNameFree ([System.String]$VMName) {
        if (Get-VM -Name $VMName -ErrorAction SilentlyContinue) {
            #$VMName is in use!"
            return $false
        } else {
            #$VMName is free!"
            return $true
        }
    }
    #endregion

    #region <Datastore>
    [Void] SetDatastore () {
        $this.datastore = (Get-Datastore | Sort-Object -Property FreeSpaceGB -Descending | Select-Object -First 1).name
    }

    [Void] SetDatastore ([String]$DataStore) {
        $this.Datastore = $DataStore
    }

    [String] GetDatastore () {
        return $this.datastore
    }
    #endregion

    #region <VMHost>
    [Void] SetVMHost () {
        $this.VMHost = Get-Cluster | Get-VMHost | Get-Random
    }

    [Void] SetVMHost ([String]$VMHost) {
        $this.VMHost = $VMHost
    }

    [String] GetVMHost () {
        return $this.VMHost
    }
    #endregion

    #region <Template>
    [Void] SetVMTemplate ([String]$VMTemplate) {
        $this.VMTemplate = Get-Template -Name $VMTemplate
    }

    [String] GetVMTemplate () {
        return $this.VMTemplate
    }
    #enregion
    #endregion

    #region <OSCusSpec>
    [void] SetOsCusSpec([System.String]$CustomFile, [System.String]$VMIp) {
        if (Get-OSCustomizationSpec -Name temp1 -ErrorAction SilentlyContinue) {
            Remove-OSCustomizationSpec -OSCustomizationSpec temp1 -Confirm:$false
        }
        $this.OSCusSpec = Get-OSCustomizationSpec -Name $CustomFile | New-OSCustomizationSpec -Name 'temp1' -Type NonPersistent

        $DefaultGateway = $VMIp.Replace($VMIp.Split(".")[-1], 254)
        Get-OSCustomizationSpec $This.OSCusSpec | Get-OSCustomizationNicMapping | Set-OSCustomizationNicMapping -IpMode UseStaticIp -IpAddress $VMIp -SubnetMask '255.255.255.0' -DefaultGateway $DefaultGateway -Dns '10.1.50.11', '10.1.50.12'
    }
    #enregion

    #endregion
}

class RDS : VM {
    [System.String]$VMName
    [System.String]$RDStemplate
    [System.String]$RDSCustomFile

    RDS () {
    }

    RDS ([System.String]$VMName, [System.String]$VMIp, [System.String]$RDStemplate, [System.String]$RDSCustomFile) {
        $this.VMName = $VMName.ToUpper()
        $this.VMIp = $VMIp
        $this.RDStemplate = $RDStemplate
        $This.RDSCustomFile = $RDSCustomFile
        $this.VMType = "RDS"
    }
}