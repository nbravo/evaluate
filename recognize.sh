CONFIG=$1
RECOGNIZER=run_recognizer.sh

source path.sh

python utils/create_recognize_script.py $CONFIG > $RECOGNIZER
chmod +x $RECOGNIZER
./$RECOGNIZER
python utils/parse_results.py
