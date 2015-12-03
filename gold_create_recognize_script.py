MAX_ACTIVE_VALUES = map(str, [5000, 6000, 7000])
BEAM_VALUES = map(str, [13])
LATTICE_BEAM_VALUES = map(str, [5])

with open('test.sh', 'w') as f:
  f.write('rm foo*\n')
  f.write('source path.sh\n')

  counter = 0
  for MAX_ACTIVE in MAX_ACTIVE_VALUES:
    for BEAM in BEAM_VALUES:
      for LATTICE_BEAM in LATTICE_BEAM_VALUES:
        f.write('nbravo[' + str(counter) + ']="--max-active=' + MAX_ACTIVE + ' --beam=' + BEAM + ' --lattice-beam=' + LATTICE_BEAM + '"\n')
        #f.write('names[' + str(counter) + ']="' + '_'.join([MAX_ACTIVE, BEAM, LATTICE_BEAM]) + '"\n')
        counter += 1

  f.write('\nhostd3.pl JOB=1:' + str(counter)  + ' foo.JOB.log echo ${nbravo[JOB]}')

