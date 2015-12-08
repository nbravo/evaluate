import re

s = ""

with open('final_and_feature_transform.nnet') as f:
  s = f.read()

matchObj = re.search(r'(<NumComponents>\s+(\d+)).*?<NumComponents>\s+(\d+)', s, re.S)

totalComponents = int(matchObj.group(2)) + int(matchObj.group(3))

s = s.replace(matchObj.group(1), '<NumComponents> ' + str(totalComponents))

matchObj = re.search(r'(</Components>.*?<Components>)', s, re.S)
s = s.replace(matchObj.group(1), '')
with open('final_with_feature_transform_as_nnet2.nnet', 'w') as f:
  f.write(s)
