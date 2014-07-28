'''
Problem 1
Create an Inverted index. Given a set of documents, an inverted index is a dictionary where each word is associated with a list of the document identifiers in which that word appears.

Mapper Input
The input is a 2 element list: [document_id, text], where document_id is a string representing a document identifier and text is a string representing the text of the document. The document text may have words in upper or lower case and may contain punctuation. You should treat each token as if it was a valid word; that is, you can just use value.split() to tokenize the string.

Reducer Output
The output should be a (word, document ID list) tuple where word is a String and document ID list is a list of Strings.


You can test your solution to this problem using books.json:

        python inverted_index.py books.json


You can verify your solution against inverted_index.json.
'''

import MapReduce
import sys

mr = MapReduce.MapReduce()

# 1) Map: Populate Dict with key = Word, and value a list with Document_id (docid). Note: a word may appear more than once in each docid, which means latter on these results will have to be filtered! 
# 2) Reduce: filter repeated docids 

def mapper(record):    
    # docid: document identifier
    # value: document contents
    docid = record[0]
    value = record[1]
    words = value.split()
    for w in words:
      mr.emit_intermediate(w, docid)
    #print mr.intermediate
    
def reducer(key, list_of_values):   
    #reduce makes'm skinny (removes duplicates docid, since a word may appear more than once in a doc):
    #For more info on Lists, sets, tupples & stuff check this: http://www.codersgrid.com/2013/06/19/introduction-to-list-set-tuple-and-dictionary-in-python/
    skinny = list(set(list_of_values))    
    mr.emit((key, skinny))



if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)