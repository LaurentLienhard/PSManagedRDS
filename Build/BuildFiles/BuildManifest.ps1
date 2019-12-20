$ErrorActionPreference = "Stop";

Write-Verbose "[BUILDMANIFEST TASK][BEGIN]"
Write-Verbose "[BUILDMANIFEST TASK] Adding functions to export..."
$FunctionsToExport = ($settings.PublicFunctions).basename

New-ModuleManifest -Path $settings.ModulePsd1 -Author $settings.Author -CompanyName $settings.CompanyName -RootModule ("./" + $settings.ProjectName + ".psm1") -Description "Test Module" -Copyright "My Company"

if ($null -ne $FunctionsToExport) {
    Update-ModuleManifest -Path $settings.ModulePsd1 -FunctionsToExport $FunctionsToExport
}

#Update-ModuleManifest -Path $settings.ModulePsd1 -RequiredModules @{ModuleName = "PSDateManagement"; ModuleVersion = "0.0.1" }
Write-Verbose "[BUILDMANIFEST TASK][END]"
