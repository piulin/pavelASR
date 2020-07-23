# FROM THE RUNNING SCRIPT
################### TRAIN MONOPHONE SYSTEM #####################################

steps/train_mono.sh --boost-silence 1.25 --nj 5 --cmd "$train_cmd" data/train data/arpa_lang exp/mono

utils/mkgraph.sh data/fst_lang exp/mono exp/mono/graph

# Copy scoring script
cp -a ../../mini_librispeech/s5/local/score.sh local/

steps/decode.sh --nj 2 --cmd "$decode_cmd" exp/mono/graph data/test exp/mono/decode_test



######################### ALIGN FOR SOME REASON ################################

steps/align_si.sh --boost-silence 1.25 --nj 5 --cmd "$train_cmd" data/train data/fst_lang exp/mono exp/mono_aligned


####################### TRAIN DELTA + DELTA-DELTA ##############################

steps/train_deltas.sh --boost-silence 1.25 --cmd "$train_cmd" 2000 10000 data/train data/fst_lang exp/mono_aligned exp/tri1

utils/mkgraph.sh data/fst_lang exp/tri1 exp/tri1/graph

steps/decode.sh --nj 4 --cmd "$decode_cmd" exp/tri1/graph data/test exp/tri1/decode_test

#################### RESCORE LANGUAGE MODEL ####################################
## mail pavel.

steps/lmrescore.sh --cmd "$decode_cmd" data/fst_lang data/fst_lang_rescored data/test exp/tri1/ exp/tri1_rescored


######################### ALIGN FOR SOME REASON ################################

steps/align_si.sh --nj 5 --cmd "$train_cmd" data/train data/fst_lang exp/tri1 exp/tri1_aligned


############### train an LDA+MLLT system #######################################

steps/train_lda_mllt.sh --cmd "$train_cmd" \
  --splice-opts "--left-context=3 --right-context=3" 2500 15000 \
  data/train data/fst_lang exp/tri1_aligned exp/tri2b

utils/mkgraph.sh data/fst_lang \
  exp/tri2b exp/tri2b/graph

steps/decode.sh --nj 5 --cmd "$decode_cmd" exp/tri2b/graph \
  data/test exp/tri2b/decode_test

# Align utts using the tri2b model
steps/align_si.sh  --nj 5 --cmd "$train_cmd" --use-graphs true \
  data/train data/fst_lang exp/tri2b exp/tri2b_aligned



####################### LDA+MLLT+SAT ###########################################

steps/train_sat.sh --cmd "$train_cmd" 2500 15000 \
  data/train data/fst_lang exp/tri2b_aligned exp/tri3b

## achtung! it's using the rescored language model.
utils/mkgraph.sh data/fst_lang \
      exp/tri3b exp/tri3b/graph

steps/decode_fmllr.sh --nj 5 --cmd "$decode_cmd" \
        exp/tri3b/graph data/test \
        exp/tri3b/decode_test
