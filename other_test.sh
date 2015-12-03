rm foo*

nbravo[0]="0"
nbravo[1]="1"
nbravo[2]="2"

echo ${nbravo[0]}
echo ${nbravo[1]}
echo ${nbravo[2]}
hostd3.pl JOB=1:3 foo.JOB.log echo "${nbravo[$JOB]}"
