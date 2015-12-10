source "$1.txt"
source "$2"

online2-wav-nnet2-latgen-faster --online=true --do-endpointing=false --config=exp/nnet2_online/nnet_a_gpu_online/conf/online_nnet2_decoding.conf --max-active=$MAX_ACTIVE --beam=$BEAM --lattice-beam=$LATTICE_BEAM --acoustic-scale=0.1 --word-symbol-table=$WORD_SYMBOL_TABLE $TRANSITION_MODEL $FST ark:$SPK2UTT "ark,s,cs:extract-segments scp,p:$WAV $SEGMENTS ark:- |" "ark:|gzip -c > $OUTDIR/lat.nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.gz"
