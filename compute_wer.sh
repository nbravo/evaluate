source $1.txt
source "$2"

cat $OUTDIR/nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.tra | utils/int2sym.pl -f 2- $WORD_SYMBOL_TABLE | sed s:\<UNK\>::g | compute-wer --text --mode=present ark:$TEST_FILT ark,p:- >& $OUTDIR/wer-nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM
