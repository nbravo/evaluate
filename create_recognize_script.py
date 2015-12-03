MAX_ACTIVE_VALUES = map(str, [5000, 6000, 7000])
BEAM_VALUES = map(str, [13])
LATTICE_BEAM_VALUES = map(str, [5])

with open('run_recognizer.sh', 'w') as f:
  f.write('source path.sh\n')

  counter = 0
  for MAX_ACTIVE in MAX_ACTIVE_VALUES:
    for BEAM in BEAM_VALUES:
      for LATTICE_BEAM in LATTICE_BEAM_VALUES:
        with open(str(counter) + '.txt', 'w') as v:
          v.write('MAX_ACTIVE={max_active}\nBEAM={beam}\nLATTICE_BEAM={lattice_beam}'.format(max_active=MAX_ACTIVE, beam=BEAM, lattice_beam=LATTICE_BEAM))
        counter += 1

  f.write('\nhostd3.pl JOB=1:' + str(counter)  + ' recognizer.JOB.log online_decode.sh JOB')
  f.write('\nhostd3.pl JOB=1:' + str(counter)  + ' lattice.JOB.log run_lattice.sh JOB')
  f.write('\nhostd3.pl JOB=1:' + str(counter)  + ' wer.JOB.log compute_wer.sh JOB')

