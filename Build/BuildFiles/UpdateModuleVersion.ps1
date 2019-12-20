$ErrorActionPreference = "Stop";

# get the contents of the module manifest file
try {
    $file = (Get-Content $settings.ModulePSD1)
} catch {
    Write-Error "Failed to Get-Content"
}

$NextVersion = Get-NextNugetPackageVersion -Name $settings.ProjectName

[version]$Version = [regex]::matches($file, "\s*ModuleVersion\s=\s'(\d*.\d*.\d*)'\s*").groups[1].value
Write-Verbose "[UPDATEVERSION TASK] Old Module Version - $Version"

# Add one to the build of the version number
[version]$NewVersion = "{0}.{1}.{2}" -f $NextVersion.Major, $NextVersion.Minor, $NextVersion.build
Write-Verbose "[UPDATEVERSION TASK] New Version - $NewVersion"

# Replace Old Version Number with New Version number in the file
try {
    (Get-Content $settings.ModulePSD1) -replace $version, $NewVersion | Out-File $settings.ModulePSD1
    Write-Verbose "[UPDATEVERSION TASK]Updated Module Version from $Version to $NewVersion"
} catch {
    $_
    Write-Error "failed to set file"
}
