source $1.txt
source "$2"

lattice-scale --inv-acoustic-scale=10 "ark:gunzip -c $OUTDIR/lat.nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.gz|" ark:- | lattice-add-penalty --word-ins-penalty=0.0 ark:- ark:- | lattice-best-path --word-symbol-table=$WORD_SYMBOL_TABLE ark:- ark,t:$OUTDIR/nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.tra
