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
 
 The benchmark will be executed individually for each of the tools. The number of runs
 will be the same for all participants. The produced output for each of the runs will be added
 to the experiments folder, in the folder corresponding to the run, tool, model, and experiment number. The combined experiment
 results will be exported to a csv file created for that experiment. 
 
 * A tool is one of the tools participating in the benchmark.
 * A model is one of the CRA input models.
 * A run is an execution of a single container.
 * An experiment is an execution of all the tools and their corresponding runs.
 * An experiment number is the id of the experiment being carried out.
 
 Current output structure:
 
 experiment-{unixtime experiment id}/{tool name}/input-model-{input model}/run-{run number}/{solution}.xmi
 
 The results csv file is compatible with this script created by Gabor Szarnyas: https://github.com/javitroya/TTC2016_Follow-up
 
 Because there is no current agreement on time, I am assuming for now that the benchmark will use time measured in nanoseconds.
 
 ## Concerns
 
 For the Excel solution I don't have an available Excel license to experiment with. I would like to ask the authors
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
 
 All solutions are to be added to the problem/ttc2016_cra/solutions/{operating system}/{solution_name} folder. 
 Add your solution to the correct operating system path. For now I have added support for linux only, but windows will
 be added shortly.
 
 In the root of your solution folder add the Dockerfile. Next to the Dockerfile add another folder called app 
 which should contain your application. Please create the {solution_name} directory and submit it as a pull request.
 
 ## Solution folder
 
 Solutions are split based on the operating system they run on: windows or linux.
 
 Add your solution to the correct stack path.
 
 In each solution directory you should ensure that your Dockerfile is added to the root.
 In that directory your compiled solution should be placed in a folder called app, next to the Dockerfile. 
 The app directory will be mounted inside the container at the path /var/app/current. You 
 should not output any files to this directory, as it is shared between runs.
 
 The solution should output for each individual run the produced model to the path /var/app/output
 which is mapped automatically to the corresponding experiment results folder.
 
 ## Testing your solution
 
 
 It is possible to test the solutions and the whole configuration using Vagrant and VirtualBox. We have
 two stacks thare are supported by our setup as detailed below.
 
 The benchmark script can be executed like this:
 
 `ruby benchmark.rb <stack>`
 
 In the command above stack can be one of windows or linux.
 
 ### Linux
 
 Once you have Vagrant and its requirements installed, run `vagrant up` from the linux infrastructure directory.
 Once the virtual machine is created, run `vagrant ssh` from the same directory and run the benchmark ruby 
 script from the /var/app/mde_bench directory.
 
 ### Windows
 
 Once you have Vagrant and its requirements installed, run `vagrant up` from the linux infrastructure directory.
 Once the virtual machine is created and provisioned with no errors, using the VirtualBox virtual machine gui menu 
 Input > Keyboard > Insert CTRL+ALT+DEL then type the password `vagrant`.
 
 Once logged into the terminal of the windows VM, run the benchmark ruby script from the C:/var/app/mde_bench directory.