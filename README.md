Online Decoding and Evaluation Scripts
======================
A handful of scripts I put together while evaluating online decoders. These are not the best scripts but bear with me.

Decoding and Evaluation
------------
The main script is `recognize.sh`, which uses host dispatch to simultaneously decode and evaluate with many different paramter values. This script takes a configuration file as an argument and outputs the results of decoding into a file called `results.txt`. For example, to run the arabic decoder you could run:

    ./recognize.sh conf/gale.conf



Converting Nnet1 to Nnet2
------------------
The online decoders use nnet2, so if you have nnet1-trained models you will need to convert them. There is a script for this located at `utils/nnet1-to-nnet2.sh`. More documentation is available within the file.


Web Usage
------------
In addition to the command-line utilities provided above, you may also want to use the web-based decoder. The pages detailing that framework are [here] and [here]. For an actual UI, see here.

