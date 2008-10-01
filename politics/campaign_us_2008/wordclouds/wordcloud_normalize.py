import nltk, re, pprint
from urllib import urlopen
import csv

def make_word_tokenizer():
    word_tokenizer_re = r'''(?x) 
                            # Numbers
          \$?(\d+(?:[\.,]\d+)*)\s*(?:million|billion|thousand)
        | (?:\d+th|\d+1st|\d+nd)\b # cardinal figures
        | \$?\d+(?:,\d{3})+   # $4,000
        | \d+:\d+(?:\s*[ap]\.m\.)?          # time
        | \$?\d+(?:\.\d+)?    # currency amounts, e.g. $12.50 
        | (?:No\. )           # abbreviations
        | (?:[ap]\.m\.)       # a.m. / p.m.
        | (?:[A-Z]\.)+        # abbreviations, e.g. U.S.A. 
        | (?:\'ve|\'d|\'s|\'ll|\'m|n\'t)\b  # contractions
        # | [^\w\s]+          # sequences of punctuation
        | (?:\w+(?:-\w+)+)     # hyphenated words
        | (?:\#\#[A-Z]+\#\#)  # notations
        | (?:\w+~\w+)         # force-joined words with tilde ~
        | \w+                 # sequences of 'word' characters 
        ''' 
    return nltk.tokenize.RegexpTokenizer(word_tokenizer_re).tokenize
    # s=("And 4:30 that ends 5.2 million 4.5 tonight.\n\nOn October 4,000 2, next $5,000  Thursday, also at 9:00 p.m. Eastern time, "); word_tokenizer(s)

try:
    word_tokenizer
except NameError:
    word_tokenizer = make_word_tokenizer()

try:
    sent_tokenizer
except NameError:
    sent_tokenizer = nltk.data.load('tokenizers/punkt/english.pickle')

try:
    tagger
except NameError:
    brown_a = nltk.corpus.brown.tagged_sents(categories='a')
    t0      = nltk.DefaultTagger('WTF') 
    t1      = nltk.UnigramTagger(brown_a, backoff=t0) 
    t2      = nltk.BigramTagger( brown_a, backoff=t1) 
    tagger  = nltk.TrigramTagger(brown_a, backoff=t2)

class SpeechAnalyzer(object):
    NOTATIONS = {
      r'--'                   : "##PAUSE##",
      r'\(sic\)'              : "##SIC##",
      r'\[mispronunciation\]' : '##MISPRONUNCIATION##',
      r'\.\.\.'               : ' ##PAUSE## '
    }
    PHRASES = [
      "wall street", "main street", "my friends", "middle class", "fannie mae", "freddie mac",
      "United States", "United States of America", 'Al Quaeda', 'Al Qaeda',
    ]

    def __init__(self,text):
        self.text  = text
        self.group_by_speaker()
        self.find_sentences()
        self.find_words()
        
    def lowerfirst(self, words):
        if (words[0]) and (not re.match(r'^(?:I|I\'(?:m|ve|d)|McCain|Obama|Afghanistan|Russia|America|Jim|China|Al|Iraq|Ireland|Spain|Tom|Osama|John)$', words[0])):
            words[0] = words[0].lower()
        return words

    def group_by_speaker(self):
        lines = re.split(r'(OBAMA|MCCAIN|LEHRER): ', self.text)[1:]
        # Break out each speaker's lines
        spkr_lines = dict([[spkr, ""] for spkr in ['OBAMA', 'MCCAIN', 'LEHRER']])
        for i in range(0, len(lines), 2):  # in groups of 2
            spkr_lines[lines[i]] += "\n\n" + lines[i+1]
        self.spkr_lines = spkr_lines

    def find_sentences(self):
        self.spkr_sents = dict((spkr, sent_tokenizer.tokenize(lines)) for spkr, lines in self.spkr_lines.iteritems())

    def normalize(self, line):
        for phrase in SpeechAnalyzer.PHRASES:
            srch = '(?i)'+re.sub(r'\s', "\\s", phrase)
            repl = re.sub(r'\s', "~", phrase)
            line = re.sub(srch, repl, line)
        line = re.sub(r'([a-zA-Z]+)n\'t', r"\1 n't", line)
        for srch, repl in SpeechAnalyzer.NOTATIONS.iteritems():
            line = re.sub(srch, repl, line)
        return line

    def tokenize(self, line):
        line = self.normalize(line)
        return self.lowerfirst(word_tokenizer(line))
    
    def find_words(self):
        self.spkr_words = dict( (spkr, [self.tokenize(sent) for sent in sents])
                          for spkr, sents in self.spkr_sents.iteritems())

    def all_words(self):
        return dict((spkr, sum(sents,[])) for spkr, sents in self.spkr_words.iteritems())

    def dump_csv(self):
        writer = csv.writer(open("temp/foo.csv", "wb"))
        for spkr, words in self.spkr_words.iteritems():
            writer.writerows(sum(
                [ [ ["%s/%s" % (wd,tag)] for wd,tag in tagger.tag(sent) if tag == 'WTF'
                    ] for sent in words ], [])) # 


text = open('rawd/words_debate_20080926-raw.txt', 'rU').read()
sa = SpeechAnalyzer(text)



# phrases = nltk.Text(words).collocations()

# United States; Senator Obama; Senator McCain; make sure; General Petraeus; bin Laden; North Korea; health care; Ronald Reagan; sit down; national security; pork barrel; Admiral Mullen; Wall Street; the United; lead question; middle class; parsing words; eight years; nuclear weapons

# cfd = nltk.ConditionalFreqDist(nltk.corpus.brown.tagged_words(categories='a'))
# dict((word, cfd[word].max()) for word in most_freq_words)
