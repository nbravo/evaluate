hostd3.pl JOB=0:0 log/recognizer.JOB.log online_decode.sh JOB 0.txt
hostd3.pl JOB=0:0 log/lattice.JOB.log lattice.sh JOB 0.txt
hostd3.pl JOB=0:0 log/wer.JOB.log compute_wer.sh JOB 0.txt
