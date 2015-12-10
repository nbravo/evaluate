CONFIG=$1
RECOGNIZER=run_recognizer.sh

source path.sh

python create_recognize_script.py $CONFIG > $RECOGNIZER
#chmod +x $RECOGNIZER
#./$RECOGNIZER
#python parse_results.py
