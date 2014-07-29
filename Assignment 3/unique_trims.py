'''
Problem 5
Consider a set of key-value pairs where each key is sequence id and each value is a string of nucleotides, e.g., GCTTCCGAAATGCTCGAA....

Write a MapReduce query to remove the last 10 characters from each string of nucleotides, then remove any duplicates generated.

Map Input
Each input record is a 2 element list [sequence id, nucleotides] where sequence id is a string representing a unique identifier for the sequence and nucleotides is a string representing a sequence of nucleotides

Reduce Output
The output from the reduce function should be the unique trimmed nucleotide strings.

You can test your solution to this problem using dna.json:

$ python unique_trims.py dna.json
You can verify your solution by comparing your result with the file unique_trims.json.


'''


import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):    
    # key: sequence id
    # value: nucleotides
    #Mapper main task is to remove the last 10 characters from each string of nucleotides
    key = record[0] 
    value = record[1] 
    #remove last values of string:
    trimmed = value[:(len(value)-10)]
    mr.emit_intermediate(trimmed,value)

    
def reducer(key, list_of_values):   
    #Reducer's main task is to count how many results are in each list_of_values per person
    #Note the key will already be unique, since it has been stored in a dict :)
    mr.emit(key)


if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)