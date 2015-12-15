# Converts nnet1 models to nnet2. This is actually a multi-step process that can be summarized as follows:
#   - Convert final.nnet to nnet2 format using the built-in kaldi tool
#   - Convert final.feature_transform to nnet2 format using the built-in kaldi tool
#   - Normalize ali_train_pdf.counts to obtain a list of priors
#   - Concatenate both nnet2 files and the list of priors to obtain the final_as_nnet2.mdl which can be used for nnet2 online decoding

nnet1-to-raw-nnet --binary=false final.nnet final_as_nnet2.nnet
nnet1-to-raw-nnet --binary=false final.feature_transform feature_transform_as_nnet2.nnet

cat final_as_nnet2.nnet feature_transform_as_nnet2.nnet > final_and_feature_transform.nnet

python merge_nnets.py

python normalize.py ali_train_pdf.counts > priors.txt

cat final.mdl final_with_feature_transform_as_nnet2.nnet priors.txt > final_as_nnet2.mdl
