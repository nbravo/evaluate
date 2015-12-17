# Converts nnet1 models to nnet2. This is actually a multi-step process that can be summarized as follows:
#   - Convert final.nnet to nnet2 format using the built-in kaldi tool
#   - Convert final.feature_transform to nnet2 format using the built-in kaldi tool
#   - Normalize ali_train_pdf.counts to obtain a list of priors
#   - Concatenate the original transition model, both nnet2 files, and the list of priors to obtain the final_as_nnet2.mdl which can be used for nnet2 online decoding

#Note that this scipt does not take any arguments. Rather, it assumes that the necessary files are present in the current directory. The files necessary are:
#  - final.mdl
#  - final.nnet
#  - final.feature_transform
#  - ali_train_pdf.counts

nnet1-to-raw-nnet --binary=false final.nnet final_as_nnet2.nnet
nnet1-to-raw-nnet --binary=false final.feature_transform feature_transform_as_nnet2.nnet

python merge_nnets.py final_as_nnet2.nnet feature_transform_as_nnet2.nnet > final_with_feature_transform_as_nnet2.nnet

python normalize.py ali_train_pdf.counts > priors.txt

cat final.mdl final_with_feature_transform_as_nnet2.nnet priors.txt > final_as_nnet2.mdl
