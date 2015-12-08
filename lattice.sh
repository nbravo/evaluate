source $1.txt

lattice-scale --inv-acoustic-scale=10 "ark:gunzip -c exp/nnet2_online/nnet_a_gpu_online/decode_test/lat.nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.gz|" ark:- | lattice-add-penalty --word-ins-penalty=0.0 ark:- ark:- | lattice-best-path --word-symbol-table=exp/tri3b/graph/words.txt ark:- ark,t:exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.tra
