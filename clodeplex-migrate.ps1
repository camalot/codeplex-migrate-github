Param (
  [Parameter(Mandatory=$true)]
  [string] $RepositoryName,
  [Parameter(Mandatory=$true)]
  [string] $ProjectName,
  [Parameter(Mandatory=$true)]
  [string] $GithubAccessToken,
  [string] $CodePlexServer = "TFS01"
)
$newRepoName = "";

$TFSRootUrl = "https://tfs.codeplex.com:443/tfs/${CodePlexServer}";

function Init-Prepare {
  process {
    choco install posh-github -y;
    choco install git-tf -y -v 2.0.3.20131219;
    choco install gittfs -y;
    # Reload the user profile
    . $PROFILE
    $env:PATH += "C:\ProgramData\chocolatey\lib\Git-TF\Tools\git-tf-2.0.3.20131219\lib";
  }
}

function New-GHRepository {
  $env:GITHUB_OAUTH_TOKEN = $GithubAccessToken;
  $formattedName = $RepositoryName -replace "/", "-"
  $newRepoName = $formattedName.ToLower();
  Write-Host "Creating repository $newRepoName";
  # -NoClone tells it not to clone the newly created repo locally. We do not want to do that
  New-GitHubRepository -Name "$newRepoName" -NoClone | Out-Null;
  if ( $global:GITHUB_API_OUTPUT -eq $null ) {
    "Unable to create new repository. Check error" | Write-Error;
    return;
  }
  $outRepo = $global:GITHUB_API_OUTPUT.name;
}

function Clone-SourceRepo {
  if($global:GITHUB_API_OUTPUT -eq $null) {
    Write-Error "Unable to detect the created repository on Github";
    return;
  }

  $tempFolder = "e:\Temp\GitMigrate";
  if(!(Test-Path -Path $tempFolder)) {
    New-Item -Path $tempFolder -Type Directory -Force | Out-Null;
  }

  Push-Location -Path $tempFolder;
  git-tf clone $TFSRootUrl "`$/$ProjectName" $RepositoryName --deep
  Push-Location -Path (Join-Path -Path $tempFolder -ChildPath $RepositoryName);

  & git remote add origin $global:GITHUB_API_OUTPUT.clone_url;
  & git remote -v;
  "Pushing repository to new remote" | Write-Host;
  & git push -u origin --all;

  Pop-Location;
  Pop-Location;
  Remove-Item -Path $tempFolder -Force -Recurse | Out-Null;
  $global:GITHUB_API_OUTPUT = $null;

}


try {
  Init-Prepare;
  New-GHRepository;
  Clone-SourceRepo;
} catch {
  $_.Exception.Message | Write-Error;
}
