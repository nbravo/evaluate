source "$1.txt"

online2-wav-nnet2-latgen-faster --online=true --do-endpointing=false --config=exp/nnet2_online/nnet_a_gpu_online/conf/online_nnet2_decoding.conf --max-active=$MAX_ACTIVE --beam=$BEAM --lattice-beam=$LATTICE_BEAM --acoustic-scale=0.1 --word-symbol-table=exp/tri3b/graph/words.txt exp/nnet2_online/nnet_a_gpu_online/final.mdl exp/tri3b/graph/HCLG.fst ark:$DATADIR/spk2utt "ark,s,cs:extract-segments scp,p:$DATADIR/wav.scp $DATADIR/segments ark:- |" "ark:|gzip -c > exp/nnet2_online/nnet_a_gpu_online/decode_test/lat.nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.gz"
