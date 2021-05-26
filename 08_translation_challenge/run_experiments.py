from batch_simulator import run_agents_in_environment

#######################################
# Two options about what to do with the agent's log messages in absence 
# of a GUI pane
def log_to_console(msg):
    print(msg)

def log_null(msg):
    pass

########################################
    

num_samples = 100
output_file_name = 'simulation_results.csv'

agents = [ #("agents/reactiveagent.py",    "NoSenseAgent"),
           #("agents/reactiveagent.py",    "SensingAgent"),
           ("agents/worldmodelagent.py",  "WorldModelAgent"),
          # ("agents/planningagent.py",    "OmniscientAgent"),
         ]

recon = {"NoSenseAgent": 'None',
         "SensingAgent": 'None',
         "WorldModelAgent": 'None',
         "OmniscientAgent": 'Full'}

write_results_to_console = True

for dirt_density in (0.1, 0.2, 0.3):
    for wall_density in (0.1, 0.2, 0.3):
        run_agents_in_environment(dirt_density, 
                          wall_density, 
                          agents, 
                          recon,
                          2000,  # Battery capacity
                          log_null, 
                          num_samples, 
                          output_file_name, 
                          write_results_to_console)
