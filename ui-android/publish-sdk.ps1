$sdkRepositoryPath = $Env:SDK_REPOSITORY_PATH 
$githubPAT = $Env:PAT_GITHUB
try {
    Set-Location "$PSScriptRoot/sdk"

    git config --global user.name "github-actions[bot]"
    git config --global user.email "github-actions[bot]@users.noreply.github.com"
    
    # Commit and push to sub module
    $remoteOrigin = "https://$githubPAT@github.com/trinsic-id/sdk-android-ui.git"
    Write-Host "Setting origin to $remoteOrigin"
    git remote set-url origin $remoteOrigin

    Write-Host "Checking out main branch"
    # If we don't do this we're in a detached head state
    git checkout main

    # Pull latest version of code
    git pull

    $packageVersion = &"$PSScriptRoot\..\get-version.ps1" -versionName "androidUIVersion";

    # Define the path to the gradle file
    $gradlePath = "./library/build.gradle.kts"

    # Read the podspec file content
    $gradleContent = Get-Content $gradlePath

    # Update the version in the gradle content
    $updatedContent = $gradleContent -replace "\s+version = `"[\d\.]+`"", "            version = `"$packageVersion`""

    # Write the updated content back to the podspec file
    $updatedContent | Set-Content $gradlePath

    Write-Host "Gradle file updated with version $packageVersion."

    Write-Host "Adding files to git"
    git add .

    Write-Host "Committing files"
    git commit -m "Publishing latest ui-android package for version $packageVersion"
    
    Write-Host "Pushing to submodule repository"
    git push origin main

    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push to submodule main"
    }

    $tagName = "$packageVersion"
    git tag $tagName
    git push origin $tagName

    # Go back to main repo and update reference
    Set-Location "$PSScriptRoot/../"
    $remoteOrigin = "https://$githubPAT@github.com/$sdkRepositoryPath.git"
    Write-Host "Setting origin to $remoteOrigin"
    git remote set-url origin $remoteOrigin

    # Update reference in main repo
    git add "ui-android/sdk"
    git commit -m "Update ui-android submodule reference to version $packageVersion"
    git push origin main
    if ($LASTEXITCODE -ne 0) {
        throw "Failed to push to our main"
    }

    # TODO: Hit jitpack post-publish to prompt it to trigger a build
}
finally {
    Pop-Location    
}