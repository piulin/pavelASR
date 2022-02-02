#!/usr/bin/env bash



steps/decode.sh --nj 2 --cmd "$decode_cmd" exp/mono/graph data/grade-test exp/mono/decode_grade-test


steps/decode.sh --nj 4 --cmd "$decode_cmd" exp/tri1/graph data/grade-test exp/tri1/decode_grade-test

steps/decode.sh --nj 5 --cmd "$decode_cmd" exp/tri2b/graph \
  data/grade-test exp/tri2b/decode_grade-test

steps/decode_fmllr.sh --nj 5 --cmd "$decode_cmd" \
        exp/tri3b/graph data/grade-test \
        exp/tri3b/decode_grade-test
