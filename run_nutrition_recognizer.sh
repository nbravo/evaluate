source path.sh

hostd3.pl JOB=0:119 recognizer.JOB.log nutrition_online_decode.sh JOB
hostd3.pl JOB=0:119 lattice.JOB.log nutrition_lattice.sh JOB
hostd3.pl JOB=0:119 wer.JOB.log nutrition_compute_wer.sh JOB