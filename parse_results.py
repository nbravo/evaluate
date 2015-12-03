import subprocess

def extractNumber(s):
  splitLine = s.split(" ")
  for word in splitLine:
    if word.replace(".", "").isdigit():
      return word
  return ""

LOG = 'exp/nnet2_online/nnet_a_gpu_online/decode_test/log/decode.nbravo.log'
TRA = 'exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo.tra'
WER = 'exp/nnet2_online/nnet_a_gpu_online/decode_test/wer_nbravo'

DATADIR = 'data/test/split30/1'
MAX_ACTIVE_VALUES = [5000, 6000, 7000]
BEAM_VALUES = [13, 14, 15]
LATTICE_BEAM_VALUES = [5, 6, 7]

with open('results.txt', 'w') as g:
  g.write("{:>16} {:>16} {:>16} {:>16} {:>16} {:>16}\n".format("Max Active", "Beam", "Lattice Beam", "Real-Time Factor", "Latency", "WER"))

  for MAX_ACTIVE in map(str, MAX_ACTIVE_VALUES):
    for BEAM in map(str, BEAM_VALUES):
      for LATTICE_BEAM in map(str, LATTICE_BEAM_VALUES):
        print 'DECODING FOR ' + ' '.join([MAX_ACTIVE, BEAM, LATTICE_BEAM])
        rtf = None
        latency = None
        wer = None

        command = constructCommand(MAX_ACTIVE, BEAM, LATTICE_BEAM, DATADIR)
        with open(LOG, 'w') as f:
          subprocess.call([command], shell=True, stdout=f, stderr=f)
        with open(TRA, 'w') as h:
          subprocess.call([traCommand()], shell=True, stdout=h, stderr=h)
        with open(WER, 'w') as i:
          subprocess.call([werCommand()], shell=True, stdout=i, stderr=i)
        with open(LOG, 'r') as f:
          for line in f:
            if line.startswith("LOG"):
              if "real-time factor" in line:
                rtf = extractNumber(line)
              if "Average delay" in line:
                latency = extractNumber(line)
        with open(WER, 'r') as w:
          for line in w:
            if "WER" in line:
              wer = extractNumber(line)
              break
        g.write("{:>16} {:>16} {:>16} {:>16} {:>16} {:>16}\n".format(MAX_ACTIVE, BEAM, LATTICE_BEAM, rtf, latency, wer))
