#$ProjectName = "BuildModuleDemo"
$Author = "LIENHARD Laurent"
$CompanyName = "My Company"

#$ProjectRoot = $PSScriptRoot
$SourceFolder = join-path $env:BHProjectPath -ChildPath "\Sources"
$RessourcesFolder = Join-Path $SourceFolder -ChildPath "\Ressources"
$Enums = Get-ChildItem -Path "$SourceFolder\Enums\" -Filter *.ps1 | Sort-Object Name
$Classes = Get-ChildItem -Path "$SourceFolder\Classes\" -Filter *.ps1 | Sort-Object Name
$PrivateFonctions = Get-ChildItem -Path "$SourceFolder\Functions\Private" -Filter *.ps1 | Sort-Object Name
$PublicFonctions = Get-ChildItem -Path "$SourceFolder\Functions\Public" -Filter *.ps1 | Sort-Object Name
$OutputDir = Join-Path $env:BHProjectPath -ChildPath "\BuildOutput\"
$BuildOutputDir = Join-Path $OutputDir -ChildPath "$env:BHProjectName\"
$ModulePSM1 = Join-Path $BuildOutputDir -ChildPath "$env:BHProjectName.psm1"
$ModulePSD1 = Join-Path $BuildOutputDir -ChildPath "$env:BHProjectName.psd1"
$UnitTestPath = Join-Path $env:BHProjectPath -ChildPath "\UnitTests"
$ResultUnitTestFile = Join-Path $UnitTestPath -ChildPath "\UnitTestsResult.xml"


$script:settings = @{
    Author             = $Author
    CompanyName        = $CompanyName
    #ProjectRoot        = $PSScriptRoot
    ProjectName        = $env:BHProjectName
    OutputDir          = $OutputDir
    BuildOutputDir     = $BuildOutputDir
    SourceFolder       = $SourceFolder
    RessourcesFodler   = $RessourcesFolder
    Enums              = $Enums
    Classes            = $Classes
    PrivateFunctions   = $PrivateFonctions
    PublicFunctions    = $PublicFonctions
    ModulePsm1         = $ModulePSM1
    ModulePsd1         = $ModulePSD1
    UnitTestPath       = $UnitTestPath
    ResultUnitTestFile = $ResultUnitTestFile
}