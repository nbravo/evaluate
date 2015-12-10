#!/bin/bash
cd /data/sls/scratch/nbravo/kaldi/egs/gale_arabic.complete/s5
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
nutrition_compute_wer.sh $1 
EOF
) >wer.$1.log
 ( nutrition_compute_wer.sh $1  ) 2>>wer.$1.log >>wer.$1.log
ret=$?
echo '#' Finished at `date` with status $ret >>wer.$1.log
[ $ret -eq 137 ] && exit 100;
touch ./q/done.6559.$SGE_TASK_ID
exit $[$ret ? 1 : 0]
## submitted with:
# 
