source $1.txt

cat exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo-nutrition-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.tra | utils/int2sym.pl -f 2- /data/sls/scratch/nbravo/gstreamer/test/models/english/nutrition/words.txt | sed s:\<UNK\>::g | compute-wer --text --mode=present ark:/data/sls/scratch/pricem/kaldi/nutrition/data/test_amt1/text_filtered ark,p:- >& exp/nnet2_online/nnet_a_gpu_online/decode_test/wer-nbravo-nutrition-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM
