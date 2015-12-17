"""
This script extracts the WER and timing info from the files created during the process of decoding and evaluation.
"""
import sys

"""
Given a line in a file, returns the first number found in the line
"""
def extractNumber(line):
  splitLine = line.split()
  for word in splitLine:
    if word.replace(".", "").isdigit():
      return word
  return ""

def constructLogName(counter):
  return 'log/recognizer.' + str(counter) + '.log'

def constructWerName(MAX_ACTIVE, BEAM, LATTICE_BEAM):
  return '{outdir}/wer-{max_active}-{beam}-{lattice_beam}'.format(max_active=MAX_ACTIVE, beam=BEAM, lattice_beam=LATTICE_BEAM, outdir=OUT_DIR)

MAX_ACTIVE_VALUES = sys.argv[1].split(" ")
BEAM_VALUES = sys.argv[2].split(" ")
LATTICE_BEAM_VALUES = sys.argv[3].split(" ")
OUT_DIR = sys.argv[4]

with open('results.txt', 'w') as g:
  g.write("{:>16} {:>16} {:>16} {:>16} {:>16} {:>16}\n".format("Max Active", "Beam", "Lattice Beam", "Real-Time Factor", "Latency", "WER"))

  counter = 0
  for MAX_ACTIVE in map(str, MAX_ACTIVE_VALUES):
    for BEAM in map(str, BEAM_VALUES):
      for LATTICE_BEAM in map(str, LATTICE_BEAM_VALUES):
        rtf = None
        latency = None
        wer = None

        with open(constructLogName(counter), 'r') as f:
          for line in f:
            if "real-time factor" in line:
              rtf = extractNumber(line)
            if "Average delay" in line:
              latency = extractNumber(line)
        with open(constructWerName(MAX_ACTIVE, BEAM, LATTICE_BEAM), 'r') as f:
          for line in f:
            if "WER" in line:
              wer = extractNumber(line)
              break
        g.write("{:>16} {:>16} {:>16} {:>16} {:>16} {:>16}\n".format(MAX_ACTIVE, BEAM, LATTICE_BEAM, rtf, latency, wer))
        counter += 1
