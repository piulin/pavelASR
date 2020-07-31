source path.sh
source cmd.sh

if [ ! -d local ]
then
  mkdir local
fi

cp -a ../../chime6/s5_track1/local/train_lms_srilm.sh local/


########################### MODIFY THE SRILM FILE ##############################

sed -i '102s/.*/less \$train_text \| sort -u > \$tgtdir\/train\.txt/' local/train_lms_srilm.sh
sed -i '103d' local/train_lms_srilm.sh

sed -i '114s/.*/less \$dev_text \| sort -u > \$tgtdir\/dev\.txt/' local/train_lms_srilm.sh
sed -i '115d' local/train_lms_srilm.sh


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
cp ../../mini_librispeech/s5/data/local/dict_nosp/extra_questions.txt data/local/dict/
echo "Succeeded :("


################### RETRIEVE THE TEXT FILE FROM THE CRAWLER ###################

mkdir -p data/crawler/

less ../../../../crawler/text.txt | tr '[:lower:]' '[:upper:]' > data/crawler/text.txt


############################ EXPAND OUR LEXICON ################################

mv data/local/dict/lexicon.txt data/local/dict/lexicon.txt.bak
cat ../../../../crawler/crawler_and_training_dictionary.txt data/local/dict/lexicon.txt.bak | sort  \
  >  data/local/dict/lexicon.txt
sed -i '1d' data/local/dict/lexicon.txt

mv data/crawler/text.txt data/crawler/text.txt.bak
cat data/local/corpus.txt data/crawler/text.txt.bak > data/crawler/text.txt


#################### MAKE THE DICTIONARY MORE RUSSIAN LIKE #####################

echo "4" >> data/local/dict/nonsilence_phones.txt

sed -i 's/T R/T 4/g' data/local/dict/lexicon.txt
sed -i 's/D R/D 4/g' data/local/dict/lexicon.txt
sed -i 's/P R/P 4/g' data/local/dict/lexicon.txt
sed -i 's/B R/B 4/g' data/local/dict/lexicon.txt
sed -i 's/G R/G 4/g' data/local/dict/lexicon.txt
sed -i 's/K R/K 4/g' data/local/dict/lexicon.txt

less data/local/dict/lexicon.txt | awk -F' {2,}|\t' '{print $1}' > /tmp/tokens.txt
less data/local/dict/lexicon.txt | awk -F' {2,}|\t' '{print $2}' | sed -e 's/ G$/ K/g' > /tmp/phone_swap.txt
paste /tmp/tokens.txt /tmp/phone_swap.txt > data/local/dict/lexicon.txt

less data/local/dict/lexicon.txt | awk -F' {2,}|\t' '{print $2}' | sed -e 's/ B$/ P/g' > /tmp/phone_swap.txt
paste /tmp/tokens.txt /tmp/phone_swap.txt > data/local/dict/lexicon.txt

less data/local/dict/lexicon.txt | awk -F' {2,}|\t' '{print $2}' | sed -e 's/ D$/ T/g' > /tmp/phone_swap.txt
paste /tmp/tokens.txt /tmp/phone_swap.txt > data/local/dict/lexicon.txt

mv data/local/dict/lexicon.txt data/local/dict/lexicon.txt.bak
less data/local/dict/lexicon.txt.bak | sort | uniq > data/local/dict/lexicon.txt

########################### PREPARE LANGUAGE THING #############################
echo "TS" >> data/local/dict/nonsilence_phones.txt
echo "IX" >> data/local/dict/nonsilence_phones.txt

utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/arpa_lang

# temporary files
rm -rf data/local/lang

########################## TRAIN THE LANGUAGE MODEL ############################

local/train_lms_srilm.sh --train-text data/crawler/text.txt --words-file data/arpa_lang/words.txt data data/local/language_model_kaldi_wsj

######################### TRANSFORM IT #########################################


utils/format_lm.sh data/arpa_lang data/local/language_model_kaldi_wsj/best_4gram.gz \
                    data/local/dict/lexicon.txt data/fst_lang
