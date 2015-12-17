CONFIG=$1
RECOGNIZER=run_recognizer.sh

source $CONFIG

# The following three values should be space-separated strings. A python script will split these strings and treat them as python lists.
MAX_ACTIVE_VALUES="4000 5000"
BEAM_VALUES="9 10 11"
LATTICE_BEAM_VALUES="2"

python utils/create_recognize_script.py $CONFIG $MAX_ACTIVE_VALUES $BEAM_VALUES $LATTICE_BEAM_VALUES > $RECOGNIZER
chmod +x $RECOGNIZER
./$RECOGNIZER
python utils/parse_results.py $MAX_ACTIVE_VALUES $BEAM_VALUES $LATTICE_BEAM_VALUES $OUTDIR
