function Install-Prerequisites {
    [CmdletBinding()]
    param (

    )

    begin {
        if ((-not (Get-Module -Name VMware.VimAutomation.Core -ListAvailable))) {
            Install-Module -Name VMware.VimAutomation.Core -AllowClobber -Scope CurrentUser -Force
        }

    }

    process {

    }

    end {

    }
}