#!/bin/bash
cd /data/sls/scratch/nbravo/kaldi/egs/gale_arabic.complete/s5
. ./path.sh
( echo '#' Running on `hostname`
  echo '#' Started at `date`
  echo -n '# '; cat <<EOF
lattice.sh $1 conf/gale.conf 
EOF
) >log/lattice.$1.log
 ( lattice.sh $1 conf/gale.conf  ) 2>>log/lattice.$1.log >>log/lattice.$1.log
ret=$?
echo '#' Finished at `date` with status $ret >>log/lattice.$1.log
[ $ret -eq 137 ] && exit 100;
touch log/q/done.19544.$SGE_TASK_ID
exit $[$ret ? 1 : 0]
## submitted with:
# 
