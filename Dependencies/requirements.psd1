@{
    PSDependOptions  = @{
        Target     = 'CurrentUser'
        Parameters = @{
            Force = $True
        }
    }


    Pester           = @{
        Version    = 'latest'
        Parameters = @{
            SkipPublisherCheck = $true
            Force              = $True
        }
    }
    psake            = 'latest'
    PSScriptAnalyzer = 'latest'
    PSDeploy         = 'Latest'
    BuildHelpers     = 'Latest'
    PSClassUtils     = 'Latest'
}