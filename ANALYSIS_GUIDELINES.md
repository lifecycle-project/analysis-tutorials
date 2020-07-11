# Analysis Guidelines
These guidelines describe how to use git in solving real research questions.

This a first draft of the **Analysis Guidelines**. Please ammend or change it if you need to.

## Doing analysis
When you are conducting analysis with a certain group of cohorts you need to take into account that you have taken the followin steps.

1. Harmonise your data according to the [harmonisation guide]()
2. [Uploaded the LifeCycle variables and harmonised data]()
3. *(when needed)* [Uploaded the additional variables and corresponding harmonised data]()
4. [Creat views to select the right variable set and create users in Opal to expose the views to the other cohorts]()
   This has to be done at each cohort.
5. [Determine which analysis-protocols you need to use]()
6. [Write you analysis and perform the actual analysis]()
7. [Determine which parts could be used in other analysis and extract them as new analysis-protocols]()

These steps are needed for doing sample analysis as well as the actual analysis. Is is imperritive that we extends the standard analysis protocols with the features we are reusing in every new analysis.

### Sample analysis
In the working group we are conducting sample analysis. These analysis are setup by participating partners. If you want to join the group please send an email to s.haakma@rug.nl or api@kund.su.dk.
When you want to add a sample analysis we are trying to maintain the following structure:

- R/sample_analysis
  - NINFEA
    - sample_analysis_ninfea.R
  - SWS
    - sample_analysis_sws.R
  - DNBC
    - sample_analysis_dnbc.R
  - etc.
  
It is not recommended to work on exactly the same file in Git. This will be available when we are going to use pull-requests in Github.

### Doing actual analysis
For each new research question create a new repository on https://github.com/lifecycle-project/

- For instance: https://github.com/lifecycle-project/new_research_question.git

You should maintain the following directory structure:
- R
  - research_question_module_1.R
  - research_question_module_2.R
  - research_question_module_3.R
- README.md

You can add a README.md to explain what you are doing on a research level explaining what question you are trying to answer and on a technical level to explain how to use the script.

All owners, that will be all people who are attached to the lifecycle-project organisation, can create new repoistories and add code.