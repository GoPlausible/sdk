# Parameters:
param (
    [Parameter(Mandatory = $true)]
    [string]$versionName
)
# Because there's a lot of small variations in version number usage across generators, generate version first and provide it via additonal properties to the generate-client.ps1 file.
# Other option was a lot of if language specific if statements inside of generate-client.
$jsonContent = Get-Content -Path "$PSScriptRoot\versions.json" -Raw | ConvertFrom-Json
$backendVersion = $jsonContent.backendVersion
$patchVersion = $jsonContent."$($versionName)patchVersion"
$packageVersion = "$backendVersion.$patchVersion"
Write-Host "Package will be created with version $packageVersion from file based API Version $version and patchVersion $patchVersion"

echo "trinsic-package-version=$packageVersion" >> $env:GITHUB_OUTPUT

return $packageVersion;