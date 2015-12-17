"""
Merges two nnets, which are in nnet2 format and whose filenames are taken in as arguments. The merge process consists of removing some of the closing tags of the first nnet and the opening tags of the second nnet. Also, the number of components is updated to be the sum of the number of components in each of the two original nnets.
"""
import sys
import re

s = ""

with open(sys.argv[1]) as f:
  s += f.read()
with open(sys.argv[2]) as f:
  s += f.read()

# Update total number of components
matches = re.search(r'(<NumComponents>\s+(\d+)).*?<NumComponents>\s+(\d+)', s, re.S)
totalComponents = int(matches.group(2)) + int(matches.group(3))
s = s.replace(matches.group(1), '<NumComponents> ' + str(totalComponents))

# Remove closing tags from the end of the first nnet and opening tags from the beginning of the second nnet
s = re.sub(r'</Components>.*?<Components>', '', s, flags=re.S)

print s
