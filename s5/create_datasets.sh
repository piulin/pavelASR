
########################## WAV EXTRACTION ######################################

echo "Extracting Wavs..."

# create dataset folders.
mkdir -p data/train/wavs
mkdir -p data/test/wavs


# exctract wavs for testing.
tools/extract_wavs.sh tools/text/1.tsv tools/video/1_installation.mp4 data/test/wavs/
tools/extract_wavs.sh tools/text/2.tsv tools/video/2_directories.mp4 data/test/wavs/
# exctract wavs for trainig.
tools/extract_wavs.sh tools/text/3.tsv tools/video/3_data.mp4 data/train/wavs/
tools/extract_wavs.sh tools/text/4.tsv tools/video/4_project.mp4 data/train/wavs/

echo "Succeeded :("

############################# wav.scp ########################################
### create the wav.scp files (test).

echo "Creating wav.scp"



mkdir -p /tmp/pavel/

if [ -f /tmp/pavel/wav_test.scp ]; then
    rm /tmp/pavel/wav_test.scp
fi

if [ -f /tmp/pavel/wav_train.scp ]; then
    rm /tmp/pavel/wav_train.scp
fi

if [ -f data/test/wav.scp ]; then
    rm data/test/wav.scp
fi

if [ -f data/train/wav.scp ]; then
    rm data/train/wav.scp
fi

speakers_test=(victoria ruth isaac pavan petra cristina anthony rrrrrrr anna tony)
speakers_train=(pavel thang pedro sarina maike isabelle alex nishan jesse xanat)


no_speakers=6 # more or less.
num_lines_test=`find data/test/wavs -type f | wc -l`
num_lines_train=`find data/train/wavs -type f | wc -l`

lines_per_file_test=$[ $num_lines_test / $no_speakers ]
lines_per_file_train=$[ $num_lines_train / $no_speakers ]

for file in data/test/wavs/*
do
  echo "$(basename $file .wav) $file" >> /tmp/pavel/wav_test.scp
done

# create the wav.scp files (train).
for file in data/train/wavs/*
do
  echo "$(basename $file .wav) $file" >> /tmp/pavel/wav_train.scp
done


split -l $lines_per_file_test /tmp/pavel/wav_test.scp /tmp/pavel/test
split -l $lines_per_file_train /tmp/pavel/wav_train.scp /tmp/pavel/train


counter=0
for file in /tmp/pavel/test*
do
  less $file | awk "{print \"${speakers_test[counter]}\"\$1\" \"\$2}" >>  data/test/wav.scp
  counter=$[ $counter + 1 ]
done

counter=0
for file in /tmp/pavel/train*
do
  echo "{print \"${speakers_train[counter]}\"\$1\" \"\$2}"
  less $file | awk "{print \"${speakers_train[counter]}\"\$1\" \"\$2}" >>  data/train/wav.scp
  counter=$[ $counter + 1 ]
done



echo "Succeeded :("

################################ UTT2spk #######################################

echo "Creating utt2spk.scp"

mkdir -p /tmp/pavel/utt2spk/

split -l $lines_per_file_test data/test/wav.scp /tmp/pavel/utt2spk/test
split -l $lines_per_file_train data/train/wav.scp /tmp/pavel/utt2spk/train

if [ -f "data/test/utt2spk" ]; then
    rm data/test/utt2spk
fi

if [ -f "data/train/utt2spk" ]; then
    rm data/train/utt2spk
fi

counter=0
for file in /tmp/pavel/utt2spk/test*
do
  less $file | awk "{print \$1 \" ${speakers_test[counter]}\"}" >>  data/test/utt2spk
  counter=$[ $counter + 1 ]
done
counter=0
for file in /tmp/pavel/utt2spk/train*
do
  less $file | awk "{print \$1 \" ${speakers_train[counter]}\"}" >>  data/train/utt2spk
  counter=$[ $counter + 1 ]
done

echo "Succeeded :("

############################## TEXT EXTRACTION #################################

echo "Extracting text"

if [ -f /tmp/pavel/text/text_test ]; then
    rm /tmp/pavel/text/text_test_unsorted
fi

if [ -f /tmp/pavel/text/text_train ]; then
    rm /tmp/pavel/text/text_train_unsorted
fi

if [ -f data/test/text ]; then
    rm data/test/text
fi

if [ -f data/train/text ]; then
    rm data/train/text
fi

mkdir -p /tmp/pavel/text/

# exctract text for testing.
tools/text_file_extraction.sh tools/text/1.tsv tools/video/1_installation.mp4 /tmp/pavel/text/text_test_unsorted
tools/text_file_extraction.sh  tools/text/2.tsv tools/video/2_directories.mp4 /tmp/pavel/text/text_test_unsorted
# exctract text for trainig.
tools/text_file_extraction.sh  tools/text/3.tsv tools/video/3_data.mp4 /tmp/pavel/text/text_train_unsorted
tools/text_file_extraction.sh  tools/text/4.tsv tools/video/4_project.mp4 /tmp/pavel/text/text_train_unsorted

less /tmp/pavel/text/text_test_unsorted | sort > /tmp/pavel/text/text_test
less /tmp/pavel/text/text_train_unsorted | sort > /tmp/pavel/text/text_train

split -l $lines_per_file_test /tmp/pavel/text/text_test /tmp/pavel/text/test
split -l $lines_per_file_train /tmp/pavel/text/text_train /tmp/pavel/text/train

counter=0
for file in /tmp/pavel/text/test*
do
  less $file | awk "{print \"${speakers_test[counter]}\"\$0}" >>  data/test/text
  counter=$[ $counter + 1 ]
done
counter=0
for file in /tmp/pavel/text/train*
do
  less $file | awk "{print \"${speakers_train[counter]}\"\$0}" >>  data/train/text
  counter=$[ $counter + 1 ]
done


echo "Succeeded :("
############################ CREATE LOCAL FOLDER ###############################

echo "Creating local folder"

if [ ! -d "data/local" ]
then
  mkdir data/local
fi

echo "Succeeded :("
########################### CREATE CORPUS FILE #################################
echo "Creating corpus file"

cut -d' ' -f2- data/train/text > data/local/corpus.txt

echo "Succeeded :("
########################### DICT THINGY ########################################
echo "Copying dictionary from libriminispeechee"

if [ ! -d "data/local/dict" ]
then
  mkdir data/local/dict
fi

cp ../../mini_librispeech/s5/data/local/dict_nosp/nonsilence_phones.txt data/local/dict/
cp ../../mini_librispeech/s5/data/local/dict_nosp/lexicon.txt data/local/dict/
cp ../../mini_librispeech/s5/data/local/dict_nosp/silence_phones.txt data/local/dict/
cp ../../mini_librispeech/s5/data/local/dict_nosp/optional_silence.txt data/local/dict/

echo "Succeeded :("

###################### LINK utils, steps, path.sh AND cmd.sh ###################

echo "Linking tools"

ln -s ../../mini_librispeech/s5/steps .
ln -s ../../mini_librispeech/s5/utils .

cp ../../mini_librispeech/s5/path.sh .
cp ../../mini_librispeech/s5/cmd.sh .

echo "Succeeded :("
############################# FIX THINGS AUTOMATICALLY ########################

echo "Fixing things..."


utils/validate_data_dir.sh data/train
utils/validate_data_dir.sh data/test

utils/fix_data_dir.sh  data/train
utils/fix_data_dir.sh  data/test

echo "Succeeded :("


########################### EXTRACT MFCC FEATURES ##############################

echo "Extracting MFCC features..."

cp -r ../../mini_librispeech/s5/conf .

source path.sh
source cmd.sh
pwd
nj=12
mfccdir=mfcc
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/test exp/make_mfcc/test $mfccdir
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train exp/make_mfcc/train $mfccdir


echo "Succeeded :("


####################### COMPUTE CMVN STATS ####################################

echo "CMVN stats..."

steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfccdir

echo "Succeeded :("
