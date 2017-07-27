require 'docker'
require 'date'
require 'csv'
require 'open3'

# Some global config
problems_path = "problems"

# Experiment config
# Get run id as unix timestamp
run_id = Time.now.to_i

experiments = 1
problem = "ttc2016_cra"
results_root = File.join(problems_path, problem, 'experiments', 'experiment-' + run_id.to_s)
solutions_root = File.join(problems_path, problem, 'solutions')
evaluation_jar = File.join(problems_path, problem, "utilities/CRAIndexCalculator.jar")

# General results path: run-{unixtime}/problem-{}/tool-{}/input-{}/experiment-{}/solution.xmi
puts "Outputting results for this run to " + results_root

# Get tools for problem
puts "Loading current tools for problem " + problem

# Run docker compose to get container configurations
containers = %x[cd problems/ttc2016_cra/solutions/ && docker-compose config --services].split(/\n/)

# Build the containers
system("cd problems/ttc2016_cra/solutions/ && docker-compose build")

puts "Found the following container configurations: "
puts containers

# Run the experiments for each configuration
for container in containers do
  (1..experiments).each do |i|
    puts "========================================================="
    puts "Running experiment " + i.to_s + " for container " + container
    system({"EXPERIMENT" => run_id.to_s, "RUN" => i.to_s}, "cd problems/ttc2016_cra/solutions/ && docker-compose run " + container)

    puts "Container done"
    puts "========================================================="
  end
end

# Delete the containers
# Insert blank envvars to avoid warning
system({"EXPERIMENT" => "", "RUN" => ""}, "cd problems/ttc2016_cra/solutions/ && docker-compose down")

# Process the results

def get_directories(path)
  Dir.entries(path)
      .reject{ |file| file =~ /^\.{1,2}$/}
      .select { |file| !File.file? file }
end

def evaluate_model(evaluation_jar, model_path)
  stdout, stderr, status = Open3.capture3("java -jar " + evaluation_jar + " " + model_path)

  if status

    # Check correctness
    # not doing anything with this as it is expected to return only valid models from the solutions
    correctness_names = /^(Correctness: )(ok)$/.match(stdout)

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
CSV.open(File.join(problems_path, problem, 'experiments', run_id.to_s + "-results.csv"), "wb") do |csv|
  for result in results
    csv << result
  end
end