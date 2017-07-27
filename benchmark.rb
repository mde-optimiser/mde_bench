require 'docker'
require 'date'

# Load problems from problems directory

def get_directories(path)
  Dir.entries(path)
      .reject{ |file| file =~ /^\.{1,2}$/}
      .select { |file| !File.file? file }
end

# Some global config

problems_path = "./problems"

# Experiment config
# Get run id as unix timestamp
run_id = Time.now.to_i

experiments = 1
problem = "ttc2016_cra"
results_root = File.join(problems_path, problem, 'experiments', 'run-' + run_id.to_s)
solutions_root = File.join(problems_path, problem, 'solutions')

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
system("cd problems/ttc2016_cra/solutions/ && docker-compose down")