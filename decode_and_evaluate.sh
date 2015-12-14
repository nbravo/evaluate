source "variable_files/$1.txt"
source "$2"

online_args=()
online_args+=( "$TRANSITION_MODEL" )
online_args+=( "$FST" )
online_args+=( "ark:$SPK2UTT" )
if [ -n "$SEGMENTS" ]; then
  online_args+=( "ark,s,cs:extract-segments scp,p:$WAV $SEGMENTS ark:- |" )
else
  online_args+=( "scp,p:$WAV" )
fi
online_args+=( "ark:|gzip -c > $OUTDIR/lat.nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.gz" )

online2-wav-nnet2-latgen-faster --online=true --do-endpointing=false --config=$CONFIG --max-active=$MAX_ACTIVE --beam=$BEAM --lattice-beam=$LATTICE_BEAM --acoustic-scale=0.1 --word-symbol-table=$WORD_SYMBOL_TABLE "${online_args[@]}"

lattice-scale --inv-acoustic-scale=10 "ark:gunzip -c $OUTDIR/lat.nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.gz|" ark:- | lattice-add-penalty --word-ins-penalty=0.0 ark:- ark:- | lattice-best-path --word-symbol-table=$WORD_SYMBOL_TABLE ark:- ark,t:$OUTDIR/nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.tra

cat $OUTDIR/nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM.tra | utils/int2sym.pl -f 2- $WORD_SYMBOL_TABLE | sed s:\<UNK\>::g | compute-wer --text --mode=present ark:$TEST_FILT ark,p:- >& $OUTDIR/wer-nbravo-$MAX_ACTIVE-$BEAM-$LATTICE_BEAM
