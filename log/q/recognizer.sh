#!/bin/bash
cd /data/sls/scratch/nbravo/kaldi/egs/gale_arabic.complete/s5
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
decode_and_evaluate.sh $1 conf/gale.conf 
EOF
) >log/recognizer.$1.log
 ( decode_and_evaluate.sh $1 conf/gale.conf  ) 2>>log/recognizer.$1.log >>log/recognizer.$1.log
ret=$?
echo '#' Finished at `date` with status $ret >>log/recognizer.$1.log
[ $ret -eq 137 ] && exit 100;
touch log/q/done.14588.$SGE_TASK_ID
exit $[$ret ? 1 : 0]
## submitted with:
# 
