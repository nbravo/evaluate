source 0.txt

online2-wav-nnet2-latgen-faster --online=true --do-endpointing=false --config=exp/nnet2_online/nnet_a_gpu_online/conf/online_nnet2_decoding.conf --max-active=$MAX_ACTIVE --beam=$BEAM --lattice-beam=$LATTICE_BEAM --acoustic-scale=0.1 --word-symbol-table=exp/tri3b/graph/words.txt exp/nnet2_online/nnet_a_gpu_online/final.mdl exp/tri3b/graph/HCLG.fst ark:$DATADIR/spk2utt "ark,s,cs:extract-segments scp,p:$DATADIR/wav.scp $DATADIR/segments ark:- |" "ark:|gzip -c > exp/nnet2_online/nnet_a_gpu_online/decode_test/lat.nbravo_other.gz"

lattice-scale --inv-acoustic-scale=10 "ark:gunzip -c exp/nnet2_online/nnet_a_gpu_online/decode_test/lat.nbravo_other.gz|" ark:- | lattice-add-penalty --word-ins-penalty=0.0 ark:- ark:- | lattice-best-path --word-symbol-table=exp/tri3b/graph/words.txt ark:- ark,t:exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo_other.tra

cat exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo_other.tra | utils/int2sym.pl -f 2- exp/tri3b/graph/words.txt | sed s:\<UNK\>::g | compute-wer --text --mode=present ark:exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/test_filt.txt ark,p:- >& exp/nnet2_online/nnet_a_gpu_online/decode_test/wer-nbravo_other

