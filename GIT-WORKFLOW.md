# GIT-workflow
In the following tutorial you can practise the basics of working with version control. In this case GIT.
There are a few main principles you have to understand.

- repositories (a set of files managed by GIT, local or remote)
- remote repository (the repostiroy where you work on together)
- commit in a repository (creating change-sets)
- pulling commits from a repository
- pushing commits to a repository

>note: Please also check: [https://www.atlassian.com/git/tutorials/learn-git-with-bitbucket-cloud](https://www.atlassian.com/git/tutorials/learn-git-with-bitbucket-cloud).
You can replace bitbucket cloud with Github.

## Changing files
When you changed a file in your repository GIT noticed it and will ask you what to do with it.

So for example:

You are writing a script: import.R.

- Create a new file

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/create_file.png" width="350px" />

- Change the file

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/edit_file.png" width="350px" />

- Save the file

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/save_file.png" width="350px" />

- Give the file a name

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/name_file.png" width="350px" />

- Check in the commit-box what changes you made

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/commit_dialog.png" width="350px" />


## Commiting files
When you changed a fileset that is of use for other people to or you are just finished with it you can commit it into the repository. 
>note: Once you commit a fileset you have need to push it as well to get it into the remote repository.

- Click on "commit"

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/commit_button.png" width="350px" />

- Select the files you want to commit

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/commit_file.png" width="350px" />

- Enter the commit message

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/commit_message.png" width="350px" />

- Click on commit and you get a commit id which you can also find on https://github.com/lifecycle-project/analysis-tutorials.git

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/commit_id.png" width="350px" />


## Pushing files
To persits the change you made on a remote repository you to synchrnise (pull) with the remote repository and store your local changes on the remote repository (push). 

- Pull from remote

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/pull_and_push.png" width="350px" />

- Result of pull

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/pull_result.png" width="350px" />

- Push local changes to remote repository

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/pull_and_push.png" width="350px" />

- Check push result

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/push_result.png" width="350px" />

When you have performed these steps the remote is in sync with your local repository,

>note: The default workflow is to start each time you work in a repository with a pull from the remote repository. This is ncessary because other contributors can have changes pushed into the remote while your not working on it. There is one exception when you start a new project than you start with an "Initial commit".



