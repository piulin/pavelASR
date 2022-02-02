#!/usr/bin/env bash

mkdir -p data/grade-test/wavs

# exctract wavs for trainig.
# tools/extract_wavs.sh tools/text/5.tsv tools/video/5_features.mp4 data/grade-test/wavs/
# tools/extract_wavs.sh tools/text/6.tsv tools/video/6_lm.mp4 data/grade-test/wavs/
# tools/extract_wavs.sh tools/text/7.tsv tools/video/7_mono.mp4 data/grade-test/wavs/
# tools/extract_wavs.sh tools/text/8.tsv tools/video/8_tri.mp4 data/grade-test/wavs/



echo "Succeeded :("


echo "Creating wav.scp"



mkdir -p /tmp/pavel/

if [ -f /tmp/pavel/wav_grade-test.scp ]; then
    rm /tmp/pavel/wav_grade-test.scp
fi


if [ -f data/grade-test/wav.scp ]; then
    rm data/grade-test/wav.scp
fi


speakers_test=(victoria ruth isaac pavan petra cristina anthony rrrrrrr anna tony)


no_speakers=6 # more or less.
num_lines_test=`find data/grade-test/wavs -type f | wc -l`

lines_per_file_test=$[ $num_lines_test / $no_speakers ]

for file in data/grade-test/wavs/*
do
  echo "$(basename $file .wav) $file" >> /tmp/pavel/wav_grade-test.scp
done



split -l $lines_per_file_test /tmp/pavel/wav_grade-test.scp /tmp/pavel/grade-test


counter=0
for file in /tmp/pavel/grade-test*
do
  echo "{print \"${speakers_test[counter]}\"\$1\" \"\$2}"
  less $file | awk "{print \"${speakers_test[counter]}\"\$1\" \"\$2}" >>  data/grade-test/wav.scp
  counter=$[ $counter + 1 ]
done

echo "Succeeded :("







echo "Creating utt2spk.scp"


echo "Creating utt2spk.scp"

mkdir -p /tmp/pavel/utt2spk/

split -l $lines_per_file_test data/grade-test/wav.scp /tmp/pavel/utt2spk/grade-test

if [ -f "data/grade-test/utt2spk" ]; then
    rm data/grade-test/utt2spk
fi


counter=0
for file in /tmp/pavel/utt2spk/grade-test*
do
  less $file | awk "{print \$1 \" ${speakers_test[counter]}\"}" >>  data/grade-test/utt2spk
  counter=$[ $counter + 1 ]
done



echo "Succeeded :("



echo "Extracting text"

if [ -f /tmp/pavel/text/grade-text_test ]; then
    rm /tmp/pavel/text/grade-text_test_unsorted
fi

if [ -f data/grade-test/text ]; then
    rm data/grade-test/text
fi

mkdir -p /tmp/pavel/text/

# exctract text for testing.
tools/text_file_extraction.sh  tools/text/5.tsv tools/video/5_features.mp4 /tmp/pavel/text/grade-text_test_unsorted
tools/text_file_extraction.sh  tools/text/6.tsv tools/video/6_lm.mp4 /tmp/pavel/text/grade-text_test_unsorted
tools/text_file_extraction.sh  tools/text/7.tsv tools/video/7_mono.mp4 /tmp/pavel/text/grade-text_test_unsorted
tools/text_file_extraction.sh  tools/text/8.tsv tools/video/8_tri.mp4 /tmp/pavel/text/grade-text_test_unsorted


less /tmp/pavel/text/grade-text_test_unsorted | sort > /tmp/pavel/text/grade-text_test

split -l $lines_per_file_test /tmp/pavel/text/grade-text_test /tmp/pavel/text/grade-test

counter=0
for file in /tmp/pavel/text/grade-test*
do
  less $file | awk "{print \"${speakers_test[counter]}\"\$0}" >>  data/grade-test/text
  counter=$[ $counter + 1 ]
done

echo "Succeeded :("

echo "VALIDATING DATA :("

utils/validate_data_dir.sh data/grade-test
utils/fix_data_dir.sh  data/grade-test




echo "Extracting MFCC features..."

cp -r ../../mini_librispeech/s5/conf .

source path.sh
source cmd.sh
nj=12
mfccdir=mfcc
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/grade-test exp/make_mfcc/grade-test $mfccdir


echo "Succeeded :("


####################### COMPUTE CMVN STATS ####################################

echo "CMVN stats..."

steps/compute_cmvn_stats.sh data/grade-test exp/make_mfcc/grade-test $mfccdir

echo "Succeeded :("
