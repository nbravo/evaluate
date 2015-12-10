source "$1.txt"
BASE_DIR=/data/sls/scratch/nbravo/gstreamer

online2-wav-nnet2-latgen-faster --online=true --do-endpointing=false --mfcc-config=$BASE_DIR/test/models/english/nutrition/conf/mfcc.conf --max-active=$MAX_ACTIVE --beam=$BEAM --lattice-beam=$LATTICE_BEAM --acoustic-scale=0.1 --word-symbol-table=$BASE_DIR/test/models/english/nutrition/words.txt $BASE_DIR/test/models/english/nutrition/experimental_final.mdl $BASE_DIR/test/models/english/nutrition/HCLG.fst ark:$DATADIR/spk2utt "scp,p:$DATADIR/wav.scp" "ark:|gzip -c > exp/nnet2_online/nnet_a_gpu_online/decode_test/lat.nbravo-nutrition-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.gz"
