source path.sh

hostd3.pl JOB=0:2 recognizer.JOB.log online_decode.sh JOB
hostd3.pl JOB=0:2 lattice.JOB.log lattice.sh JOB
hostd3.pl JOB=0:2 wer.JOB.log compute_wer.sh JOB