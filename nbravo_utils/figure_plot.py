import matplotlib.pyplot as plt
import sys
import getopt

def plot_beam(data, fixed_max_active, fixed_lattice_beam):
  wer = []
  rtf = []
  beam = []

  for values in data:
    if values[0] == fixed_max_active and values[2] == fixed_lattice_beam:
      beam.append(values[1])
      rtf.append(values[3])
      wer.append(values[5])
  plt.figure(1)
  plt.subplot(311)
  plt.plot(beam, rtf)
  plt.xlabel('Beam')
  plt.ylabel('RTF')
  plt.subplot(313)
  plt.plot(beam, wer)
  plt.xlabel('Beam')
  plt.ylabel('WER')

def plot_lattice_beam(data, fixed_max_active, fixed_beam):
  wer = []
  latency = []
  lattice_beam = []

  for values in data:
    if values[0] == fixed_max_active and values[1] == fixed_beam:
      lattice_beam.append(values[2])
      latency.append(values[4])
      wer.append(values[5])
  plt.figure(2)
  plt.subplot(311)
  plt.plot(lattice_beam, latency)
  plt.xlabel('Lattice Beam')
  plt.ylabel('Latency')
  plt.subplot(313)
  plt.plot(lattice_beam, wer)
  plt.xlabel('Lattice Beam')
  plt.ylabel('WER')

def read_data(input_file):
  data = []
  with open(input_file) as f:
    first_line = True
    for line in f:
      if not first_line:
        data.append(map(float, line.split()))
      else:
        first_line = False
  return data

def main(argv):

  input_file = 'decode_test_1_results/results.txt'
  fixed_max_active = 5000
  fixed_beam = 13
  fixed_lattice_beam = 5

  try:
    opts, args = getopt.getopt(argv,"hi:m:b:l:",["input_file=", "max_active=","beam=", "lattice_beam="])
  except:
    print 'figure_plot.py -i <input_file> -m <max_active> -b <beam> -l <lattice_beam>'
    sys.exit(2)
  for opt, arg in opts:
    if opt == '-h':
      print help_text
      sys.exit()
    if opt in ["-i", "--input_file"]:
      input_file = arg
    if opt in ["-m", "--max_active"]:
      fixed_max_active = arg
    if opt in ["-b", "--beam"]:
      fixed_beam = arg
    if opt in ["-l", "--lattice_beam"]:
      fixed_lattice_beam = arg

  data = read_data(input_file)
  plot_lattice_beam(data, fixed_max_active, fixed_beam)
  plot_beam(data, fixed_max_active, fixed_lattice_beam)
  plt.show()

if __name__ == "__main__":
  main(sys.argv[1:])
