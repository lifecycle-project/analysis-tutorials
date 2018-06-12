# Analysis tutorials
Tutorial scripts to use with LifeCycle analyses.

## Setup your environment
We have a few steps to help you setup your environment
- Version control and sharing of analysis
- RStudio-account management

### Version-control and sharing of analysis
We want to use version-control to setup a platform where you can share your analysis script and also be able to obtain an older version of the script. 

We are using github to do file-versioning and sharing. 

1. Create an account on github: [join github](https://github.com/join)

2. Create a person access token: [create access token](https://help.github.com/articles/creating-a-personal-access-token-for-the-command-line)
  - Follow the steps until *10* (note that the token will only be presented once by Github)
  - You will use the token in **Step 4** so keep it on your clipboard

3. In R-Studio create a new project
- Create a new project

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/new_project.png" width="350px" />

- Choose "From version control" 

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/from_version_control.png" width="350px" />

- Choose "Git"

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/git.png" width="350px" />

- Enter the project url from Github

<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/project_url.png" width="350px" />

4. Setup your credentials for the project
- Open up a terminal 
 
<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/terminal.png" width="350px" />

- Execute the following command and be aware that you paste you username:token in the github-url. So: *"git remote set-url origin https://**username**:**token**@github.com/lifecycle-project/analysis-tutorials"*
 
<img src="https://github.com/lifecycle-project/analysis-tutorials/raw/master/manuals/images/git_credentials.png" width="500px">   
  
## Tutorials
There are three levels of tutorials we now distinguish.

- [beginner](#beginner-tutorials)
- [novice](#novice-tutorials)
- [advanced](#advanced-tutorials) (only for experieced R-users)

There are some prerequisites for these tutorials. You have to upload datasets to:

- https://opal1.domain.org
- https://opal2.domain.org

The datasets are speficyfied by in the difficulty level paragraphs.

### Beginner tutorials
The beginners tutorials are containing a set of excersizes that are fit for beginning R and DataSHIELD users.

For the **beginners**-tutorial you need to create a "Project": **Tutorials**
and then create a table called: **tutorial_beginner**
Use these files for the beginners tutorial:
- [metadata](sample-data/beginners/opal_dataset_metadata.xlsx)
- [dataset1](sample-data/beginners/opal1_dataset.csv)
- [dataset2](sample-data/beginners/opal2_dataset.csv)

#### First steps in DataSHIELD
*Created by [Sido Haakma](https://github.com/sidohaakma)*

An age analyses on 2 datasets in the 2 test-opals.

### Novice tutorials
If you already have some experience in doing R-analyses you can do these tutorials.

#### More specific implementation on LifeCycle-framework
*Created by Angela Pinot de Moira*

This tutorial includes a more specific anlaysis and datamanipulation implementation on LifeCycle data.

### Advanced tutorials
You can attend these tutorials if are certified by Angela or Sido in the LifeCycle project.

#### Some more exploration on how to use DataSHIELD
*Created by [Tom Bishop](https://github.com/tombishop1)*

This tutorial includes some data manipulation in R and some sample statitics you can perform in R.
