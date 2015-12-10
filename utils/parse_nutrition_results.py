def extractNumber(s):
  splitLine = s.split(" ")
  for word in splitLine:
    if word.replace(".", "").isdigit():
      return word
  return ""

def constructLog(counter):
  return 'recognizer.' + str(counter) + '.log'

def constructWer(MAX_ACTIVE, BEAM, LATTICE_BEAM):
  return 'exp/nnet2_online/nnet_a_gpu_online/decode_test/wer-nbravo-nutrition-{max_active}-{beam}-{lattice_beam}'.format(max_active=MAX_ACTIVE, beam=BEAM, lattice_beam=LATTICE_BEAM)

MAX_ACTIVE_VALUES = map(str, [3000, 4000, 5000])
BEAM_VALUES = map(str, [9, 10, 11, 12, 13, 14, 15, 16])
LATTICE_BEAM_VALUES = map(str, [2, 3, 4, 5, 6])

with open('results.txt', 'w') as g:
  g.write("{:>16} {:>16} {:>16} {:>16} {:>16} {:>16}\n".format("Max Active", "Beam", "Lattice Beam", "Real-Time Factor", "Latency", "WER"))

  counter = 0
  for MAX_ACTIVE in map(str, MAX_ACTIVE_VALUES):
    for BEAM in map(str, BEAM_VALUES):
      for LATTICE_BEAM in map(str, LATTICE_BEAM_VALUES):
        rtf = None
        latency = None
        wer = None

        with open(constructLog(counter), 'r') as f:
          for line in f:
            if "real-time factor" in line:
              rtf = extractNumber(line)
            if "Average delay" in line:
              latency = extractNumber(line)
        with open(constructWer(MAX_ACTIVE, BEAM, LATTICE_BEAM), 'r') as f:
          for line in f:
            if "WER" in line:
              wer = extractNumber(line)
              break
        g.write("{:>16} {:>16} {:>16} {:>16} {:>16} {:>16}\n".format(MAX_ACTIVE, BEAM, LATTICE_BEAM, rtf, latency, wer))
        counter += 1
