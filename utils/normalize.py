"""
Takes an ali_train_pdf.counts file (which should be passed in as an argument) normalizes it. Expects the format of the file to be a series of numbers surrounded by brackets. These brackets are removed, the numbers are noramalized, and the brackets are added back when the final result is printed
"""
import sys

if __name__ == "__main__":
  fileName = sys.argv[1]
  counts = []

  with open(fileName) as f:
    contents = f.read()

    contents = contents.replace("[", "").replace("]", "").strip()
    counts = map(int, contents.split())

    total = sum(counts)
    normalized_counts = [float(old_count)/total for old_count in counts]

    print '[ ' + ' '.join(map(str, normalized_counts)) + ' ]'

