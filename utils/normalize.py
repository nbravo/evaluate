import sys

if __name__ == "__main__":
  fileName = sys.argv[1]
  counts = []

  with open(fileName) as f:
    contents = f.read()

    contents = contents.split("[")[1]
    contents = contents.split("]")[0]
    counts = map(int, contents.strip().split(' '))

    total = sum(counts)
    new_counts = [old_count * 1.0 / total for old_count in counts]
    result = '[ ' + ' '.join(map(str, new_counts)) + ' ]'
    print result

