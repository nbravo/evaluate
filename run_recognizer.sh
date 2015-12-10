source path.sh

hostd3.pl JOB=0:79 recognizer.JOB.log online_decode.sh JOB
hostd3.pl JOB=0:79 lattice.JOB.log lattice.sh JOB
hostd3.pl JOB=0:79 wer.JOB.log compute_wer.sh JOB