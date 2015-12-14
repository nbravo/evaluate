import sys

if __name__ == "__main__":
  CONFIG = sys.argv[1]
  MAX_ACTIVE_VALUES = map(str, [4000])
  BEAM_VALUES = map(str, [9])
  LATTICE_BEAM_VALUES = map(str, [2])

  counter = 0
  for MAX_ACTIVE in MAX_ACTIVE_VALUES:
    for BEAM in BEAM_VALUES:
      for LATTICE_BEAM in LATTICE_BEAM_VALUES:
        with open('variable_files/' + str(counter) + '.txt', 'w') as v:
          v.write('MAX_ACTIVE={max_active}\nBEAM={beam}\nLATTICE_BEAM={lattice_beam}\n'.format(max_active=MAX_ACTIVE, beam=BEAM, lattice_beam=LATTICE_BEAM))
        counter += 1

  print 'hostd3.pl JOB=0:{str_counter} log/recognizer.JOB.log decode_and_evaluate.sh JOB {config}'.format(str_counter=str(counter-1), config=CONFIG)

