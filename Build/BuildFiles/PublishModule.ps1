$ErrorActionPreference = "Stop";

Write-Verbose "[PUBLISH TASK][BEGIN]"
Publish-Module -Name $settings.ProjectName -NuGetApiKey $PSGalleryApiKey -Verbose -Confirm:$false -Force