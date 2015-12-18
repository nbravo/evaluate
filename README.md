Online Decoding and Evaluation Scripts
======================
A handful of scripts I put together while evaluating online decoders. They are not particularly clean but bear with me.

Converting Nnet1 to Nnet2
------------------
The online decoders use nnet2, so any models trained with nnet1 will need to be converted. The script for this is  `utils/nnet1-to-nnet2.sh`. More documentation is available within the file. If used correctly, running this script will result in a `.mdl` file suitable for use in our online decoding setups.

Command-Line Decoding
------------

Decoding and Evaluating
------------
The main script is `recognize.sh`, which decodes audio and evaluates the results for a given decoder setup. The point of this script is to use host dispatch to run multiple different jobs in parallel, where each job runs with different values for the arguments passed to the online recognizer. It is currently written to accept multiple different values for the `--max_active`, `--lattice_beam`, and `--beam` parameters, but hopefully the idea should extend to other parameters as well. This script takes a configuration file as an argument and outputs the results of decoding into a file called `results.txt`. For example, to run the arabic decoder you would use:

    ./recognize.sh conf/gale.conf

If you have no interest in running multiple jobs and instead want to run a single job with a single set of parameter values, it would probably be easier to look at `decode_and_evaluate.sh`, which contains the commands necessary for decoding and evaluating for a single job. It is currently written as a subroutine of the larger `recognize.sh` script but it should be simple to adapt it to run as a standalone script.


Web-based Decoding
------------
In addition to the command-line decoding utilities provided above, there is also a web-based decoder. The web-based decoder integrates with the Gstreamer plugin for Kaldi.

For detailed information on getting that set up, see
https://github.com/alumae/kaldi-gstreamer-server
and
https://github.com/alumae/gst-kaldi-nnet2-online
This setup is already downloaded and compiled at `/data/sls/scratch/nbravo/yifans_version`

For an example implementation of a UI, see
https://github.com/yifan/dictate.js

