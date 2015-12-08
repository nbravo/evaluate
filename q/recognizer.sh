#!/bin/bash
cd /data/sls/scratch/nbravo/kaldi/egs/gale_arabic.complete/s5
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
online_decode.sh $1 
EOF
) >recognizer.$1.log
 ( online_decode.sh $1  ) 2>>recognizer.$1.log >>recognizer.$1.log
ret=$?
echo '#' Finished at `date` with status $ret >>recognizer.$1.log
[ $ret -eq 137 ] && exit 100;
touch ./q/done.19409.$SGE_TASK_ID
exit $[$ret ? 1 : 0]
## submitted with:
# 
