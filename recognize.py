import subprocess
import time

def decodeCommand(values, DATADIR):
  return 'online2-wav-nnet2-latgen-faster --online=true --do-endpointing=false --config=exp/nnet2_online/nnet_a_gpu_online/conf/online_nnet2_decoding.conf --max-active=' + values[0] + ' --beam=' + values[1] + ' --lattice-beam=' + values[2] + ' --acoustic-scale=0.1 --word-symbol-table=exp/tri3b/graph/words.txt exp/nnet2_online/nnet_a_gpu_online/final.mdl exp/tri3b/graph/HCLG.fst ark:' + DATADIR + '/spk2utt "ark,s,cs:extract-segments scp,p:' + DATADIR + '/wav.scp ' + DATADIR + '/segments ark:- |" "ark:|gzip -c > exp/nnet2_online/nnet_a_gpu_online/decode_test/lat.nbravo_' + '_'.join(values) + '.gz"'

def traCommand(values):
  return 'lattice-scale --inv-acoustic-scale=10 "ark:gunzip -c exp/nnet2_online/nnet_a_gpu_online/decode_test/lat.nbravo_' + '_'.join(values) + '.gz|" ark:- | lattice-add-penalty --word-ins-penalty=0.0 ark:- ark:- | lattice-best-path --word-symbol-table=exp/tri3b/graph/words.txt ark:- ark,t:exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo_' + '_'.join(values) + '.tra'

def werCommand(values):
  return 'cat exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo_' + '_'.join(values) + '.tra | utils/int2sym.pl -f 2- exp/tri3b/graph/words.txt | sed s:\<UNK\>::g | compute-wer --text --mode=present ark:exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/test_filt.txt ark,p:-'

def extractNumber(s):
  splitLine = s.split(" ")
  for word in splitLine:
    if word.replace(".", "").isdigit():
      return word
  return ""

def constructLog(values):
  return 'exp/nnet2_online/nnet_a_gpu_online/decode_test/log/decode.nbravo_' + '_'.join(values) + '.log'

def constructTra(values):
  return 'exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo_' + '_'.join(values) +  '.tra'

def constructWer(values):
  return 'exp/nnet2_online/nnet_a_gpu_online/decode_test/wer_nbravo_' + '_'.join(values)

DATADIR = 'data/test/split30/2'
MAX_ACTIVE_VALUES = [5000, 5500, 6000, 6500, 7000]
BEAM_VALUES = [11, 12, 13, 14, 15]
LATTICE_BEAM_VALUES = [3, 4, 5, 6, 7]

start = time.time()
for MAX_ACTIVE in map(str, MAX_ACTIVE_VALUES):
  for BEAM in map(str, BEAM_VALUES):
    for LATTICE_BEAM in map(str, LATTICE_BEAM_VALUES):
      print 'Decoding for ' + ' '.join([MAX_ACTIVE, BEAM, LATTICE_BEAM])
      command = decodeCommand((MAX_ACTIVE, BEAM, LATTICE_BEAM), DATADIR)
      with open(constructLog((MAX_ACTIVE, BEAM, LATTICE_BEAM)), 'w') as f:
        subprocess.call([command], shell=True, stdout=f, stderr=f)
for MAX_ACTIVE in map(str, MAX_ACTIVE_VALUES):
  for BEAM in map(str, BEAM_VALUES):
    for LATTICE_BEAM in map(str, LATTICE_BEAM_VALUES):
      command = traCommand((MAX_ACTIVE, BEAM, LATTICE_BEAM))
      with open(constructTra((MAX_ACTIVE, BEAM, LATTICE_BEAM)), 'w') as f:
        subprocess.call([command], shell=True, stdout=f, stderr=f)
for MAX_ACTIVE in map(str, MAX_ACTIVE_VALUES):
  for BEAM in map(str, BEAM_VALUES):
    for LATTICE_BEAM in map(str, LATTICE_BEAM_VALUES):
      command = werCommand((MAX_ACTIVE, BEAM, LATTICE_BEAM))
      with open(constructWer((MAX_ACTIVE, BEAM, LATTICE_BEAM)), 'w') as f:
        subprocess.call([command], shell=True, stdout=f, stderr=f)

with open('results.txt', 'w') as g:
  g.write("{:>16} {:>16} {:>16} {:>16} {:>16} {:>16}\n".format("Max Active", "Beam", "Lattice Beam", "Real-Time Factor", "Latency", "WER"))
  for MAX_ACTIVE in map(str, MAX_ACTIVE_VALUES):
    for BEAM in map(str, BEAM_VALUES):
      for LATTICE_BEAM in map(str, LATTICE_BEAM_VALUES):
        rtf = None
        latency = None
        wer = None
        with open(constructWer((MAX_ACTIVE, BEAM, LATTICE_BEAM)), 'r') as f:
          for line in f:
            if "WER" in line:
              wer = extractNumber(line)
              break
        with open(constructLog((MAX_ACTIVE, BEAM, LATTICE_BEAM)), 'r') as f:
          for line in f:
            if line.startswith("LOG"):
              if "real-time factor" in line:
                rtf = extractNumber(line)
              if "Average delay" in line:
                latency = extractNumber(line)

        g.write("{:>16} {:>16} {:>16} {:>16} {:>16} {:>16}\n".format(MAX_ACTIVE, BEAM, LATTICE_BEAM, rtf, latency, wer))
end = time.time()

print 'time elapsed: '
end - start
