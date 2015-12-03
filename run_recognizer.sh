source path.sh

hostd3.pl JOB=1:3 recognizer.JOB.log online_decode.sh JOB
hostd3.pl JOB=1:3 lattice.JOB.log run_lattice.sh JOB
hostd3.pl JOB=1:3 wer.JOB.log compute_wer.sh JOB