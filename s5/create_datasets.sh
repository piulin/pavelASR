
########################## WAV EXTRACTION ######################################

# create dataset folders.
mkdir -p data/train/wavs
mkdir -p data/test/wavs


# exctract wavs for testing.
tools/extract_wavs.sh tools/text/1.tsv tools/video/1_installation.mp4 data/test/wavs/
tools/extract_wavs.sh tools/text/2.tsv tools/video/2_directories.mp4 data/test/wavs/
# exctract wavs for trainig.
tools/extract_wavs.sh tools/text/3.tsv tools/video/3_data.mp4 data/train/wavs/
tools/extract_wavs.sh tools/text/4.tsv tools/video/4_project.mp4 data/train/wavs/



############################### wav.scp ########################################
# create the wav.scp files (test).

for file in data/test/wavs/*
do
  echo "$(basename $file .wav) $file" >> data/test/wav.scp
done


# create the wav.scp files (train).
for file in data/train/wavs/*
do
  echo "$(basename $file .wav) $file" >> data/train/wav.scp
done

################################ UTT2spk #######################################
speakers_test=(victoria ruth isaac pavan petra cristina anthony rrrrrrr anna tony)
speakers_train=(pavel thang pedro sarina maike isabelle alex nishan jesse xanat)


no_speakers=6 # more or less.
num_lines_test=`wc data/test/wav.scp -l | cut -d' ' -f1`
num_lines_train=`wc data/train/wav.scp -l | cut -d' ' -f1`

lines_per_file_test=$[ $num_lines_test / $no_speakers ]
lines_per_file_train=$[ $num_lines_train / $no_speakers ]

mkdir -p /tmp/pavel/

split -l $lines_per_file_test data/test/wav.scp /tmp/pavel/test
split -l $lines_per_file_train data/train/wav.scp /tmp/pavel/train

if [ -f "data/test/utt2spk" ]; then
    rm data/test/utt2spk
fi

if [ -f "data/train/utt2spk" ]; then
    rm data/train/utt2spk
fi

counter=0
for file in /tmp/pavel/test*
do
  less $file | awk "{print \$1 \" ${speakers_test[counter]}\"}" >>  data/test/utt2spk
  counter=$[ $counter + 1 ]
done
counter=0
for file in /tmp/pavel/train*
do
  less $file | awk "{print \$1 \" ${speakers_train[counter]}\"}" >>  data/train/utt2spk
  counter=$[ $counter + 1 ]
done



############################## TEXT EXTRACTION #################################

if [ -f data/test/text ]; then
    rm data/test/text
fi

if [ -f data/train/text ]; then
    rm data/train/text
fi


# exctract text for testing.
tools/text_file_extraction.sh tools/text/1.tsv tools/video/1_installation.mp4 data/test/text
tools/text_file_extraction.sh  tools/text/2.tsv tools/video/2_directories.mp4 data/test/text
# exctract text for trainig.
tools/text_file_extraction.sh  tools/text/3.tsv tools/video/3_data.mp4 data/train/text
tools/text_file_extraction.sh  tools/text/4.tsv tools/video/4_project.mp4 data/train/text


############################ CREATE LOCAL FOLDER ###############################

if [ ! -d "data/local" ]
then
  mkdir data/local
fi

########################### CREATE CORPUS FILE #################################

cut -d' ' -f2- data/train/text > data/local/corpus.txt


########################### DICT THINGY ########################################

if [ ! -d "data/local/dict" ]
then
  mkdir data/local/dict
fi

cp ../../mini_librispeech/s5/data/local/dict_nosp/nonsilence_phones.txt data/local/dict/
cp ../../mini_librispeech/s5/data/local/dict_nosp/lexicon.txt data/local/dict/
cp ../../mini_librispeech/s5/data/local/dict_nosp/silence_phones.txt data/local/dict/
cp ../../mini_librispeech/s5/data/local/dict_nosp/optional_silence.txt data/local/dict/


###################### LINK utils, steps, path.sh AND cmd.sh ###################


ln -s ../../mini_librispeech/s5/steps .
ln -s ../../mini_librispeech/s5/utils .

cp ../../mini_librispeech/s5/path.sh .
cp ../../mini_librispeech/s5/cmd.sh .

# ############################# FIX THINGS AUTOMATICALLY ########################
#
# utils/validate_data_dir.sh data/train
# utils/validate_data_dir.sh data/train
#
# utils/fix_data_dir.sh  data/train
# utils/fix_data_dir.sh  data/test
