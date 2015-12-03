#!/bin/bash
cd /data/sls/scratch/nbravo/kaldi/egs/gale_arabic.complete/s5
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
bash $1.txt 
EOF
) >foo.$1.log
 ( bash $1.txt  ) 2>>foo.$1.log >>foo.$1.log
ret=$?
echo '#' Finished at `date` with status $ret >>foo.$1.log
[ $ret -eq 137 ] && exit 100;
touch ./q/done.23966.$SGE_TASK_ID
exit $[$ret ? 1 : 0]
## submitted with:
# 
