RESULTS_DIR=~/results

mv exp/nnet2_online/nnet_a_gpu_online/decode_test/lat.nbravo* $RESULTS_DIR
mv exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/nbravo* $RESULTS_DIR
mv exp/nnet2_online/nnet_a_gpu_online/decode_test/wer-nbravo* $RESULTS_DIR
mv *log* $RESULTS_DIR
mv *.txt $RESULTS_DIR
