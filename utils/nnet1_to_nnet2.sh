source ~/path.sh

nnet1-to-raw-nnet --binary=false final.nnet final_as_nnet2.nnet
nnet1-to-raw-nnet --binary=false final.feature_transform feature_transform_as_nnet2.nnet

cat final_as_nnet2.nnet feature_transform_as_nnet2.nnet > final_and_feature_transform.nnet

#python merge_nnets.py final_as_nnet2.nnet feature_transform_as_nnet2.nnet
python merge_nnets.py

python /data/sls/scratch/nbravo/utils/normalize.py ali_train_pdf.counts > priors.txt

cat final.mdl final_with_feature_transform_as_nnet2.nnet priors.txt > final_as_nnet2.mdl
