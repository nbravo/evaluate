# The overall script which performs all of the decoding and evaluating. Takes
# a conf file as an argument, examples of which can be found in the conf/
# directory.
#
# This script first uses create_recognize_script.py to create the script which does
# the decoding and evaluating, which it then runs. It then uses parse_results.py
# to exract the timing and WER info from the generated files.

CONFIG=$1
RECOGNIZER=recognize_script.sh

source $CONFIG

# The following three variables should be strings of space-separated values.
# A python script will split these strings and treat them as python lists.
#
# These are the parameters that will be sent to the recognizer. Each combination
# will run as a separate job.
MAX_ACTIVE_VALUES="4000 5000"
BEAM_VALUES="9 10 11"
LATTICE_BEAM_VALUES="2"

python utils/create_recognize_script.py $CONFIG "$MAX_ACTIVE_VALUES" "$BEAM_VALUES" "$LATTICE_BEAM_VALUES" > $RECOGNIZER
chmod +x $RECOGNIZER
./$RECOGNIZER
python utils/parse_results.py "$MAX_ACTIVE_VALUES" "$BEAM_VALUES" "$LATTICE_BEAM_VALUES" "$OUTDIR"
