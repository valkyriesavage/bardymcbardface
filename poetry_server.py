from collections import defaultdict
import json
import gzip
import random
import math
import re
import selectors
import socket
import sys
import traceback

# third-party
import markovify
import nltk
from nltk.corpus import wordnet as wn
import pronouncing

# project
import libserver

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
        for line in gzip.open("gutenberg-poetry-corpus/gutenberg-poetry-v001.ndjson.gz"):
            self.all_lines.append(json.loads(line.strip()))
        self.by_rhyming_part = self.build_rhyming_dict()
        self.forward_markov = self.build_markov()
        self.reverse_markov = self.build_markov(backwards=True)

    '''
    Build up a dictionary of lists:
        pronounciations to lists of words to lists of lines ending with those words
    '''
    def build_rhyming_dict(self):
        by_rhyming_part = defaultdict(lambda: defaultdict(list))
        for line in self.all_lines:
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
        return by_rhyming_part

    '''
    Create a list of synonyms from a word.
    '''
    def generate_synonyms_for_word(self, word):
        synonyms = []
        for syn in wn.synsets(word):
            for lm in syn.lemmas():
                     synonyms.append(lm.name())#adding into synonyms
        return set(synonyms)

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
    def pick_rhyme_for_word(self, word, forbidden_pronunciations=[], line=True):
        pronunciations = pronouncing.phones_for_word(word)
        for forbidden in forbidden_pronunciations:
            if forbidden in pronunciations:
                # what the fuck... how can this happen?
                pronunciations.remove(forbidden)
            else:
                print("WHAAAT?? word: {} pronunciations: {} forbidden: {}".format(word, pronunciations, forbidden))
        if len(pronunciations) > 0:
            # choose a pronunciation of the word at random and extract the rhyme phonemes
            chosen_pronunciation = random.choice(pronunciations)
            rhyming_part = pronouncing.rhyming_part(chosen_pronunciation)
            # consider the other words which rhyme with these phonemes
            various_rhymes = self.by_rhyming_part[rhyming_part]
            rhyme_words = list(various_rhymes.keys())
            if len(rhyme_words) > 1 and word in rhyme_words:
                # sometimes it doesn't show up, if it's the only line with that ending.
                rhyme_words.remove(word) # don't rhyme it with itself
            if len(rhyme_words) == 0:
                # sadness. try another pronunciation
                return self.pick_rhyme_for_word(word,
                                                forbidden_pronunciations + [chosen_pronunciation],
                                                line=line)
            rhyme_word = random.choice(rhyme_words)
            if line:
                # return a whole line
                return random.choice(various_rhymes[rhyme_word])
            # just return a word
            return rhyme_word
        # if we don't have any pronunciations... just return the word
        return word

    '''
    Given a line, pick a line that ends with another word which rhymes with it.
    '''
    def pick_rhyme_for_line(self, line_to_rhyme, line=True):
        match = re.search(r'(?P<lastword>\b\w+\b)\W*$', line_to_rhyme)
        if match:
            last_word = match.group('lastword')
            rhymed = self.pick_rhyme_for_word(last_word, forbidden_pronunciations=[], line=line)
            # if we aren't trying to get a whole line, or the rhyme we got is
            # larger than just a word, return it
            if not line or not rhymed == last_word:
                return rhymed
        # if we are totally screwed, just repeat the line
        return line_to_rhyme

    '''
    Given a set of words, try to generate a line that starts with one of them
    '''
    def generate_line_from_concept(self,synonym_seq):
        random.shuffle(list(synonym_seq))
        for synonym in synonym_seq:
            try:
                line = self.forward_markov.make_sentence_with_start(random.choice(synonym_seq), strict=False, max_chars=60)
            except:
                continue
        return line

    '''
    Given a word, try to generate a line that ends with it
    '''
    def generate_line_for_rhyme(self, end_rhyme):
        try:
            backwards_sentence = self.reverse_markov.make_sentence_with_start(end_rhyme, strict=True, max_chars=60).split(' ')
        except:
            # if we can't make a sentence that starts this way... return -1 and try another rhyme
            return -1
        backwards_sentence.reverse()
        forwards_sentence = " ".join(backwards_sentence)
        return forwards_sentence

    '''
    given a list of concepts (which can be tuples with synonyms)
    and a rhyming scheme (AABB, ABAB, ABBA, whatever):
    * create a poem with lines that have those concepts
    * lines paired with concept lines will be rhymed to them
    * if the rhyme scheme list is not long enough for the concept list it will be repeated
    the lines in this poem will be generated on-the-fly
    '''
    def concepts_to_rhyming_scheme_generate(self, concept_list, scheme=SONNET):
        poem = ''
        # first off, check the lengths
        num_concepts = len(concept_list)
        num_lines = len(set(scheme.replace(STANZA_BREAK,'')))
        # the number of concepts we can use is equal to the number of different letters
        have_enough_lines_for_concepts = num_concepts <= num_lines
        if not have_enough_lines_for_concepts:
            # if we don't have enough stanzas, add more
            shortfall_multiplier = math.ceil(len(concept_list)/len(set(scheme.replace(STANZA_BREAK,''))))
            scheme = STANZA_BREAK.join([scheme]*shortfall_multiplier)
            num_lines = num_lines * shortfall_multiplier
        have_enough_concepts_for_lines = (num_concepts == num_lines)
        while not have_enough_concepts_for_lines:
            # if we don't have enough concepts, just choose something to keep talking about
            concept_list.append(random.choice(concept_list))
            num_concepts = len(concept_list)
            have_enough_concepts_for_lines = (num_concepts == num_lines)
        concepts_used = 0
        # now, parse the scheme
        for stanza in scheme.split(':'):
            rhyme_scheme_pieces = set(stanza)
            num_rhymes_in_stanza = len(rhyme_scheme_pieces)
            stanza_dict = {}
            # take the first n concepts and zip them to rhymes
            for scheme_piece,concept in zip(sorted(rhyme_scheme_pieces),
                                            concept_list[concepts_used:concepts_used+num_rhymes_in_stanza]):
                # how many lines do we need to rhyme with this?
                num_rhyme_lines = stanza.count(scheme_piece)
                original_line = self.generate_line_from_concept(concept)
                stanza_dict[scheme_piece] = [original_line]
                for rhyme_line in range(num_rhyme_lines - 1):
                    # we need a new line
                    tries = 10
                    while tries > 0:
                        rhymed_line_end = self.pick_rhyme_for_line(original_line, line=False)
                        rhymed_line = self.generate_line_for_rhyme(rhymed_line_end)
                        if not rhymed_line == -1:
                            break
                        tries = tries - 1
                    if rhymed_line == -1:
                        # if we never got a reasonable rhymed line generated, repeat the line
                        rhymed_line = original_line
                    stanza_dict[scheme_piece].append(rhymed_line)
            # reassemble the stanza
            for scheme_piece in stanza:
                poem += stanza_dict[scheme_piece].pop(0) + '\n'
            poem += '\n'
            # now remove those concepts, since we dealt with them
            concepts_used = concepts_used + num_rhymes_in_stanza
        return poem

    '''
    given a list of concepts (which can be tuples with synonyms)
    and a rhyming scheme (AABB, ABAB, ABBA, whatever):
    * create a poem with lines that have those concepts
    * lines paired with concept lines will be rhymed to them
    * if the rhyme scheme list is not long enough for the concept list it will be repeated
    the lines in this poem will come from the existing corpus
    '''
    def concepts_to_rhyming_scheme(self, concept_list, scheme=SONNET):
        poem = ''
        # first off, check the lengths
        # the number of concepts we can use is equal to the number of different letters
        if len(concept_list) > len(set(scheme.replace(STANZA_BREAK,''))):
            # if we don't have enough stanzas, add more
            scheme = (scheme+STANZA_BREAK)*math.ceil(len(concept_list)/len(set(scheme.replace(STANZA_BREAK,''))))
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
            for scheme_piece,concept in zip(sorted(rhyme_scheme_pieces),
                                            concept_list[concepts_used:concepts_used+num_rhymes_in_stanza]):
                # how many lines do we need to rhyme with this?
                num_rhyme_lines = stanza.count(scheme_piece)
                original_line = self.pick_line_for_synonyms(concept)
                stanza_dict[scheme_piece] = [original_line]
                for rhyme_line in range(num_rhyme_lines - 1):
                    stanza_dict[scheme_piece].append(
                        self.pick_rhyme_for_line(original_line))
            # reassemble the stanza
            for scheme_piece in stanza:
                poem += stanza_dict[scheme_piece].pop(0) + '\n'
            poem += '\n'
            # now remove those concepts, since we dealt with them
            concepts_used = concepts_used + num_rhymes_in_stanza
        return poem

    '''
    take a bunch of lines and build a markov model from them
    '''
    def build_markov(self, backwards=False, lines=250000):
        big_poem = [line['s'] for line in random.sample(self.all_lines, lines)]
        if backwards:
            # we want to make a model that predicts what comes _before_ a word
            # so to do this we want to reverse each line... word by word #tedious
            for l_idx, line in enumerate(big_poem):
                busted = line.split(" ")
                busted.reverse()
                line = " ".join(busted)
                big_poem[l_idx] = line
        big_poem = '\n'.join(big_poem)
        model = markovify.NewlineText(big_poem)
        return model

''' much of this code from https://github.com/realpython/materials/blob/master/python-sockets-tutorial/appserver.py '''
class Socketeer:
    HOST = '127.0.0.1'  # Standard loopback interface address (localhost)
    PORT = 65432        # Port to listen on (non-privileged ports are > 1023)

    def __init__(self):
        self.sel = selectors.DefaultSelector()
        lsock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # Avoid bind() exception: OSError: [Errno 48] Address already in use
        lsock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        lsock.bind((self.HOST, self.PORT))
        lsock.listen()
        print("listening on", (self.HOST, self.PORT))
        lsock.setblocking(False)
        self.sel.register(lsock, selectors.EVENT_READ, data=None)

    def accept_wrapper(self, sock):
        conn, addr = sock.accept()  # Should be ready to read
        print("accepted connection from", addr)
        conn.setblocking(False)
        message = libserver.Message(self.sel, conn, addr)
        self.sel.register(conn, selectors.EVENT_READ, data=message)

    def run(self):
        try:
            while True:
                events = self.sel.select(timeout=None)
                for key, mask in events:
                    if key.data is None:
                        self.accept_wrapper(key.fileobj)
                    else:
                        message = key.data
                        try:
                            message.process_events(mask)
                        except Exception:
                            print(
                                "main: error: exception for",
                                f"{message.addr}:\n{traceback.format_exc()}",
                            )
                            message.close()
        except KeyboardInterrupt:
            print("caught keyboard interrupt, exiting")
        finally:
            self.sel.close()

if __name__ == '__main__':
    s = Socketeer()
    s.run()
