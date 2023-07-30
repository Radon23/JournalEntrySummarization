#!/usr/bin/env python
# coding: utf-8


# Importing pandas and numpy library
from nltk.tokenize import sent_tokenize
from nltk.corpus import stopwords
import nltk
import re
import sys
import bz2
import pandas as pd
import numpy as np
import networkx as nx
import pickle


# importing NLTK library
nltk.download('stopwords')
nltk.download('punkt')
stop_words = set(stopwords.words("english"))


# Return a sentence-tokenized copy of *text*, using NLTK's recommended sentence tokenizer(currently .PunktSentenceTokenizerfor the specified language).
def sent_token(a):
    sentence = []
    sentence.append(sent_tokenize(a))
    sentences = [y for x in sentence for y in x]
    # Printing sentences[0]
#     print(sentences)
    return sentences


# Defining a function to remove stopwords from a sentences
def remove_stopwords(sen):
    sen_new = " ".join([i for i in sen if i not in stop_words])
    return sen_new


# loading a txt file into wordembedded as dictionary


def summarize(a):
    # wordembedd2 = bz2.BZ2File("Text_Summarization\wordembed", 'rb')
    # wordembedd = pickle.load(wordembedd2)
    # wordembedd2.close()
    wordembedd = pickle.load(open("API\wordembed.pkl", 'rb'))

    sentences = sent_token(a)
    # print(len(wordembedd))
    # wordembedd
    cleansentences = pd.Series(sentences).str.replace("[^a-zA-Z]", " ")
    cleansentences = [s.lower() for s in cleansentences]
    # print(cleansentences)
    stop_words = stopwords.words('english')
    # len(stop_words)
# Cleaning the stopwords in the data
    clean_sentences = [remove_stopwords(r.split()) for r in cleansentences]
# cleaning and preprocessing the sentences
    # Creating vectors for the sentences
    sentence_vectors = []
    for i in clean_sentences:
        if len(i) != 0:
            temp = sum([wordembedd.get(w, np.zeros((50,)))
                       for w in i.split()])/(len(i.split())+0.001)
        else:
            temp = np.zeros((100,))
        sentence_vectors.append(temp)
    # Checking for the similarities to summarize text
    matric = np.zeros([len(sentences), len(sentences)])
    from sklearn.metrics.pairwise import cosine_similarity
    for i in range(len(sentences)):
        for j in range(len(sentences)):
            if i != j:
                matric[i][j] = cosine_similarity(sentence_vectors[i].reshape(
                    1, 50), sentence_vectors[j].reshape(1, 50))[0, 0]
# matrix of vectors
    # matric
# Importing networkx library
# onverting the matric similarity matrix into the graph
    nx_graph = nx.from_numpy_array(matric)
    # print(nx_graph)
    scores = nx.pagerank(nx_graph)
    ranked_sentences = sorted(
        ((scores[i], s) for i, s in enumerate(sentences)), reverse=True)
    num_sentences = min(5, len(ranked_sentences))
# printing the article with summary
    print("Article:")
    print(a)
    print('\n')
    print("Summary:")
    summary = []
    for i in range(num_sentences):
        summary += [ranked_sentences[i][1]]
    summary = sorted(summary, key=lambda x: sentences.index(x))
    sen = ""
    for i in summary:
        sen += i+" "
    return sen


print(summarize("HELLo how are you . I hope you are fine with this attempt. Hopefully you won't have any problems. I had a good day today. Hopefully you did too soo yeah. Hope tomorrow is a good day too and we open up."))
