MAX_ACTIVE_VALUES = map(str, [3000, 4000, 5000])
BEAM_VALUES = map(str, [9, 10, 11, 12, 13, 14, 15, 16])
LATTICE_BEAM_VALUES = map(str, [2, 3, 4, 5, 6])
DATADIR = '/data/sls/scratch/pricem/kaldi/nutrition/data/test_amt1'

with open('run_nutrition_recognizer.sh', 'w') as f:
  f.write('source path.sh\n')

  counter = 0
  for MAX_ACTIVE in MAX_ACTIVE_VALUES:
    for BEAM in BEAM_VALUES:
      for LATTICE_BEAM in LATTICE_BEAM_VALUES:
        with open(str(counter) + '.txt', 'w') as v:
          v.write('MAX_ACTIVE={max_active}\nBEAM={beam}\nLATTICE_BEAM={lattice_beam}\nDATADIR={datadir}'.format(max_active=MAX_ACTIVE, beam=BEAM, lattice_beam=LATTICE_BEAM, datadir=DATADIR))
        counter += 1

  f.write('\nhostd3.pl JOB=0:' + str(counter-1)  + ' recognizer.JOB.log nutrition_online_decode.sh JOB')
  f.write('\nhostd3.pl JOB=0:' + str(counter-1)  + ' lattice.JOB.log nutrition_lattice.sh JOB')
  f.write('\nhostd3.pl JOB=0:' + str(counter-1)  + ' wer.JOB.log nutrition_compute_wer.sh JOB')

