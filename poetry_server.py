import json
import gzip
import random
import math
import re

# third-party
import markovify
import pronouncing

STANZA_BREAK = ":"
LIMERICK = 'AABBA{}'.format(STANZA_BREAK)
COUPLET = 'AA{}'.format(STANZA_BREAK)
TRIPLET = 'AAA{}'.format(STANZA_BREAK)
INTERLEAVE = 'ABAB{}'.format(STANZA_BREAK)
SONNET = 'ABAB{0}CDCD{0}EFEF{0}GG'.format(STANZA_BREAK)

class GutenbergRhymer:

    '''
        set up the corpus
    '''
    def __init__(self):
        self.all_lines = []
        for line in gzip.open("gutenberg-poetry-v001.ndjson.gz"):
            self.all_lines.append(json.loads(line.strip()))
        self.build_rhyming_dict()

    '''
    Build up a dictionary of lists:
        pronounciations to lists of words to lists of lines ending with those words
    '''
    def build_rhyming_dict(self):
        by_rhyming_part = defaultdict(lambda: defaultdict(list))
        for line in all_lines:
            text = line['s']
            if not(32 < len(text) < 48): # only use lines of uniform lengths
                continue
            match = re.search(r'(\b\w+\b)\W*$', text)
            if match:
                last_word = match.group()
                pronunciations = pronouncing.phones_for_word(last_word)
                for pronunciation in pronunciations:
                    rhyming_part = pronouncing.rhyming_part(pronunciation)
                    # group by rhyming phones (for rhymes) and words (to avoid duplicate words)
                    by_rhyming_part[rhyming_part][last_word.lower()].append(text)
        self.by_rhyming_part = by_rhyming_part

    '''
    From the corpus, select a random line which contains one of the synonyms offered
    '''
    def pick_line_for_synonyms(self, synonym_seq):
        if not type(synonym_seq) == tuple:
            synonym_seq = (synonym_seq)
        thing_lines = [line['s'] for line in self.all_lines if
                       re.search(r'\b{}\b'.format(random.choice(synonym_seq)),
                                 line['s'], re.I)]
        return random.choice(thing_lines)

    '''
    Given a word, pick a line that rhymes to it
    '''
    def pick_rhyme_line_for_word(self, word, forbidden_pronunciations=[]):
        pronunciations = pronouncing.phones_for_word(last_word)
        for forbidden in forbidden_pronunciations:
            pronunciations.remove(forbidden)
        if len(pronunciations) > 0:
            # choose a pronunciation of the word at random and extract the rhyme phonemes
            chosen_pronunciation = random.choice(pronunciations)
            rhyming_part = pronouncing.rhyming_part()
            # consider the other words which rhyme with these phonemes
            various_rhymes = self.by_rhyming_group[rhyming_part]
            rhyme_words = list(various_rhymes.keys())
            if len(rhyme_words) > 1 and last_word in rhyme_words:
                # sometimes it doesn't show up, if it's the only line with that ending.
                rhyme_words.remove(last_word) # don't rhyme it with itself
            if len(rhyme_words) == 0:
                # sadness. try another pronunciation
                forbidden_pronunciations.append(chosen_pronunciation)
                return self.pick_rhyme_for_word(word, forbidden_pronunciations)
            rhyme_word = random.choice(rhyme_words)
            return random.choice(various_rhymes[rhyme_word])

    '''
    Given a line, pick a line that ends with another word which rhymes with it.
    '''
    def pick_rhyme_line_for_line(self, line):
        match = re.search(r'(?P<lastword>\b\w+\b)\W*$', line)
        if match:
            last_word = match.group('lastword')
            pronunciations = pronouncing.phones_for_word(last_word)
            if len(pronunciations) > 0:
                # choose a pronounciation of the word at random and extract the rhyme phonemes
                rhyming_part = pronouncing.rhyming_part(random.choice(pronunciations))
                # consider the other words which rhyme with these phonemes
                various_rhymes = self.by_rhyming_group[rhyming_part]
                rhyme_words = list(various_rhymes.keys())
                if len(rhyme_words) > 1 and last_word in rhyme_words:
                    # sometimes it doesn't show up, if it's the only line with that ending.
                    rhyme_words.remove(last_word) # don't rhyme it with itself
                rhyme_word = random.choice(rhyme_words)
                return random.choice(various_rhymes[rhyme_word])
        return line

        '''
        given a list of concepts (which can be tuples with synonyms)
        and a rhyming scheme (AABB, ABAB, ABBA, whatever):
        * create a poem with lines that have those concepts
        * lines paired with concept lines will be rhymed to them
        * if the rhyme scheme list is not long enough for the concept list it will be repeated
        '''
        def concepts_to_rhyming_scheme(self, concept_list, scheme=SONNET):
            poem = ''
            # first off, check the lengths
            # the number of concepts we can use is equal to the number of different letters
            if len(concept_list) > len(set(scheme.replace(STANZA_BREAK,''))):
                # if we don't have enough stanzas, add more
                scheme = scheme*math.ceil(len(concept_list)/len(set(scheme.replace(STANZA_BREAK,''))))
            while len(concept_list) < len(set(scheme.replace(STANZA_BREAK,''))):
                # if we don't have enough concepts, just choose something to keep talking about
                concept_list.append(random.choice(concept_list))
            concepts_used = 0
            # now, parse the scheme
            for stanza in scheme.split(':'):
                rhyme_scheme_pieces = set(stanza)
                num_rhymes_in_stanza = len(rhyme_scheme_pieces)
                stanza_dict = {}
                # take the first n concepts and zip them to rhymes
                for scheme_piece,concept in zip(rhyme_scheme_pieces,
                                                concept_list[concepts_used:concepts_used+num_rhymes_in_stanza]):
                    # how many lines do we need to rhyme with this?
                    num_rhyme_lines = stanza.count(scheme_piece)
                    original_line = self.pick_line_for_synonyms(concept)
                    stanza_dict[scheme_piece] = [original_line]
                    for rhyme_line in range(num_rhyme_lines - 1):
                        stanza_dict[scheme_piece].append(
                            self.pick_rhyme_line_for_line(original_line, by_rhyming_group))
                # reassemble the stanza
                for scheme_piece in stanza:
                    poem += stanza_dict[scheme_piece].pop(0) + '\n'
                poem += '\n'
                # now remove those concepts, since we dealt with them
                concepts_used = concepts_used + num_rhymes_in_stanza
            return poem
