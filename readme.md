## clodeplex-migrate-github
This is a powershell script that will export your project from CodePlex over to GitHub. It will transfer your changeset history over to the GitHub repository.

#### Usage

```
.\clodeplex-migrate.ps1 -GithubAccessToken xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx -RepositoryName github-repository-name -ProjectName codeplex-project-name -CodePlexServer TFS01
```

#### GitHubAccessToken
This requires a [GitHub Personal Access Token][ghtoken] in order to gain access to create the repository.

#### RepositoryName
This is the name of the repository to create

#### ProjectName
This is the TFS Project Name on CodePlex. This can be a path. It is everything after '$/' in the TFS path. This can allow you to clone from a specific TFS branch.

#### CodePlexServer
This is the TFS instance your project is located on. Usually looks like _TFS01_

[ghtoken]: https://github.com/settings/tokens
