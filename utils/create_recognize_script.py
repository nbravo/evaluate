""" This entire script is a somewhat ugly hack. We want to use host dispatch to run the same command in different jobs but with different arguments for each job. However, each the commands for each job can only be differentiated by their job number. This script takes each combination of parameters and writes their values to special files named according to their job number. I.e., it creates a file named '0.txt' containing the values of the parameters for the first job. Each job then sources the appropriate variable file and runs using the values in that file."""

import sys

if __name__ == "__main__":
  CONFIG = sys.argv[1]
  MAX_ACTIVE_VALUES = sys.argv[2].split(" ")
  BEAM_VALUES = sys.argv[3].split(" ")
  LATTICE_BEAM_VALUES = sys.argv[4].split(" ")

  counter = 0
  for MAX_ACTIVE in MAX_ACTIVE_VALUES:
    for BEAM in BEAM_VALUES:
      for LATTICE_BEAM in LATTICE_BEAM_VALUES:
        with open('variable_files/' + str(counter) + '.txt', 'w') as v:
          v.write('MAX_ACTIVE={max_active}\nBEAM={beam}\nLATTICE_BEAM={lattice_beam}\n'.format(max_active=MAX_ACTIVE, beam=BEAM, lattice_beam=LATTICE_BEAM))
        counter += 1

  NUM_JOBS = len(MAX_ACTIVE_VALUES) * len(BEAM_VALUES) * len(LATTICE_BEAM_VALUES)
  print 'hostd3.pl JOB=0:{numJobs} log/recognizer.JOB.log decode_and_evaluate.sh JOB {config}'.format(numJobs=(NUM_JOBS-1), config=CONFIG)

