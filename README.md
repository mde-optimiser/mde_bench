# MDE Optimisation benchmark tools

## Discussion

 * How should we benchmark the time taken to run a solution?
  
    > Should we run (time) on the container startup command or rely on the tool builders?
    
    > Should each solution author output the experiment duration using their own measuring method a
    and provide their result in microseconds in a file alongside their produced model?
    
    > Should we provide a command wrapper script that measures the time to completion for each 
    solution?
    
    > Any other suggestions/ideas?
 
 ## Assumptions
 
 The optimisation will be executed individually for each model for a number of runs, each run is called an experiment. The number of runs
 will be the same for all participants. The produced output for each of the experiments will be added
 to the experiments folder, in the folder corresponding to the run, tool, model, and experiment number.
 
 * A run is an execution of all the tools.
 * A tool is one of the tools participating in the benchmark.
 * A model is one of the CRA input models.
 * An experiment number is the number of the experiment being ran for the tool with the corresponding model.
 
 Current output structure:
 
 run-{unixtime}/problem-{problem name}/tool-{tool name}/input-{inout model}/experiment-{experiment number}/solution.xmi
 
 ## Concerns
 
 It would seem that there are still some issues with running docker consistently on IAAS hardware. I have not 
 encountered any issues in the past, but there are recent reports that the AWS infrastructure delays container
 startup after a certain number of restarts. Ref article here.
 
 For the Excel solution i do not have an available Excel license to experiment with. I would like to ask the authors
 to verify the terms of the excel license they are planning to use, to ensure that it can be used in the cloud and more
 specifically on AWS cloud.
 
 ## Docker files
 
 Docker files should be created for each solution ensuring that all
 the necessary tool dependencies are available in the image. There are a number of tutorials
 online on how this can be done. Authors are also welcome to use the MDEO Dockerfile as an example.
 
 The container entry point should be a one line command that can take parameters to
 run your solutions with the various agreed run configuration as well as
 the required input models. If the command is more complex, this should be
 converted to a script that takes the required parameters. The command should terminate gracefully
 once the experiment is completed, and the output model file is correctly saved in the output directory.
 
 All solutions are to be added to the problem/ttc2016_cra/solutions/{solution_name} folder
 Please create the {solution_name} directory in your pull request in the previously indicated
 path.
 
 ### Solution folder
 
 In each solution directory you should ensure that your Dockerfile is added to the root
 and that the solution root directory resides in the app directory next to the Dockerfile. 
 The app directory will be mounted inside the container at the path /var/app/current. You 
 should not output any files to this directory, as it is shared between runs.
 
 The solution should output for each individual run the produced model to the path /var/app/output
 which is mapped automaticaly to the corresponding experiment results folder.
