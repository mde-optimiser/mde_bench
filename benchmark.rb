require 'date'
require 'csv'
require 'open3'
require 'yaml'
require 'fileutils'

if ARGV.length != 1 || !["linux", "windows"].include?(ARGV[0])
  puts "Incorrect parameter found."
  puts "Run script by specifying one of the stacks: windows or linux"
  exit
end

stack = ARGV[0]


#stdout, stderr, status = Open3.capture3({"RUN" => "envi-123"}, "echo %RUN%")
#puts stdout
#puts "---------------------------"
#stdout, stderr, status = Open3.capture3({"RUN" => "envi-123"}, "powershell -command echo $env:RUN")
#puts stdout
#exit

# Some global config
problems_path = "problems"

# Experiment config
# Get run id as unix timestamp
run_id = Time.now.to_i

experiments = 3
problem = "ttc2016_cra"
results_root = File.join(problems_path, problem, 'experiments', 'experiment-' + run_id.to_s)
solutions_root = File.join(problems_path, problem, 'solutions/')
evaluation_jar = File.join(problems_path, problem, "utilities/CRAIndexCalculator.jar")

# General results path: run-{unixtime}/problem-{}/tool-{}/input-{}/experiment-{}/solution.xmi
puts "Outputting results for this run to " + results_root

# Get tools for problem
puts "Loading current tools for problem " + problem

# Run docker compose to get container configurations
#containers = %x[cd problems/ttc2016_cra/solutions/linux/ && docker-compose config --services].split(/\n/)
stdout, stderr, status = Open3.capture3("cd problems/ttc2016_cra/solutions/"+ stack + " && docker-compose config --services")
containers = stdout.split(/\n/)

# Build the containers
stdout, stderr, status = Open3.capture3("cd problems/ttc2016_cra/solutions/linux/ && docker-compose build")

puts "Found the following container configurations: "
puts containers

# Run the experiments for each configuration
for container in containers do
  (1..experiments).each do |i|
    puts "========================================================="
    puts "Running experiment " + i.to_s + " for container " + container

    # This is not required for older yum versions of docker-compose, however on new versions it doesn't
    # https://github.com/docker/compose/issues/2781
    thing = YAML.load_file(solutions_root + stack + "/docker-compose.yml")

    thing['services'].each do | service, value|
      value['volumes'].each do | volume |

        host_volume_path = File.expand_path(File.join(solutions_root, stack, volume.split(":")[0]))

        if !volume.include? "experiments"

          # Check the service app directory exists
          if !File.directory? host_volume_path
            puts "Expected application directory does not exist: " + host_volume_path
            puts "Check configuration for service: " + service
            exit
          end

          puts "Skipping creation of volume path: " + host_volume_path

          next
        end

        #Only assumes relative paths before :
        # replace environment variables in config path
        experiment_path = File.join(host_volume_path)

        environment_variables = {"$EXPERIMENT" => run_id.to_s, "$RUN" => i.to_s}
        environment_variables.each {|k,v| experiment_path.sub!(k,v)}

        puts "Creating experiment output path at: " + experiment_path
        # add some error handling
        FileUtils.mkdir_p(experiment_path)
      end
    end

    Open3.capture3({"EXPERIMENT" => run_id.to_s, "RUN" => i.to_s}, "powershell cd problems/ttc2016_cra/solutions/" + stack +" && docker-compose run " + container)
    puts "Container done"
    puts "========================================================="
  end
end

# Delete the containers
# Insert blank envvars to avoid warning
# system({"EXPERIMENT" => "", "RUN" => ""}, "cd problems/ttc2016_cra/solutions/linux/ && docker-compose down")
Open3.capture3({"EXPERIMENT" => "", "RUN" => ""}, "cd problems/ttc2016_cra/solutions/" + stack + "/ && docker-compose down")

# Process the results

def get_directories(path)
  Dir.entries(path)
      .reject{ |file| file =~ /^\.{1,2}$/}
      .select { |file| !File.file? file }
end

def evaluate_model(evaluation_jar, model_path)
  stdout, stderr, status = Open3.capture3("java -jar " + evaluation_jar + " " + model_path)

  if status

    # Check correctness, if Correctness: ok not present it means the model is invalid
    correctness = /^(Correctness: )(ok)$/.match(stdout)

    # If the model is not valid, output no cra
    if correctness == nil
      return nil
    end

    # Return its CRA value
    matches = /^(This makes a CRA-Index of: )(.*)$/.match(stdout)
    return matches[2]

  else
    puts stderr
  end

end

solutions = get_directories(results_root)
results = [["tool","input","CRA-Index","time"]]

# Iterate through the solutions, models and runs and add the row to CSV for each produced solution
for solution in solutions
  models = get_directories(File.join(results_root, solution))

  for model in models
    model_runs = get_directories(File.join(results_root, solution, model))

    for model_run in model_runs

      model_run_path = File.join(results_root, solution, model, model_run)

      Dir.glob(File.join(model_run_path, "*.xmi")) {|file|

        # Extract the CRA value from the evaluation artifact output
        cra_value = evaluate_model(evaluation_jar, file)

        # Extract run information such as tool info, input model from the solution model path
        tool_info = /^([a-zA-Z0-9_-]+\/){4}([a-zA-Z0-9\-]+){1}(\/input-model-)([A-Z]){1}/.match(file)
        run = [tool_info[2], tool_info[4], cra_value]
        results.push(run)
      }

    end
  end
end

# Save the results to CSV
CSV.open(File.join(problems_path, problem, 'experiments', "results-" + run_id.to_s + ".csv"), "wb") do |csv|
  for result in results
    csv << result
  end
end