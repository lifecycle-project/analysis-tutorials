# Analysis Guidelines

These guidelines describe how to use git in solving real research questions.

This a first draft of the **Analysis Guidelines**. Please ammend or change it if you need to.

## Sample analysis
The following directory structure should be used.

- sample_analysis
  - NINFEA
    - sample_analysis_ninfea.R
  - SWS
    - sample_analysis_sws.R
  - DNBC
    - sample_analysis_dnbc.R
  - etc.
  
In the sample analysis directory you can work on the same file, but it is not recommended.

## Real analysis
For each new research question create a new repository on https://github.com/lifecycle-project/

- For instance: https://github.com/lifecycle-project/new_research_question.git

You should maintain the following directory structure:
- R
  - research_question.R
- README.md

You can add a README to explain what you are doing on a research level explaining what question you are trying to answer and on a technical level to explain how to use the script.

All owners, that will be all people who are attached to the lifecycle-project organisation, can create new repoistories and add code.