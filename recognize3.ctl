cat exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/1_5000_14_6.tra | utils/int2sym.pl -f 2- exp/tri3b/graph/words.txt | sed s:\<UNK\>::g | compute-wer --text --mode=present ark:exp/nnet2_online/nnet_a_gpu_online/decode_test/scoring/test_filt.txt ark,p:- > exp/nnet2_online/nnet_a_gpu_online/decode_test/wer_1_5000_14_6
----------
