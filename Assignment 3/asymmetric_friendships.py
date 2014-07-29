'''
Problem 4
The relationship "friend" is often symmetric, meaning that if I am your friend, you are my friend. Implement a MapReduce algorithm to check whether this property holds. Generate a list of all non-symmetric friend relationships.

Map Input
Each input record is a 2 element list [personA, personB] where personA is a string representing the name of a person and personB is a string representing the name of one of personA's friends. Note that it may or may not be the case that the personA is a friend of personB.

Reduce Output
The output should be the full symmetric relation. For every pair (person, friend), you will emit BOTH (person, friend) AND (friend, person). However, be aware that (friend, person) may already appear in the dataset, so you may produce duplicates if you are not careful.

You can test your solution to this problem using friends.json:

$ python asymmetric_friendships.py friends.json
You can verify your solution by comparing your result with the file asymmetric_friendships.json.
'''

import MapReduce
import sys

mr = MapReduce.MapReduce()

def mapper(record):    
    # key: record origin
    # value: record_id
    ###Mapper main task is to group each person in the intermediate Dict, and list its frinds (in the list_of_values), 
    #as well the other direction of the friendship (assymetric); so this way we cover all possible set 
    #(BUT have duplicate values);
    key = record[0] #Name of person
    value = record[1] #Friend of person
    mr.emit_intermediate(key, [key,value])
    #by putting the other way round, we are able to list all other people who mentioned that were friends with person X, 
    #but person X did not list them as friends..
    mr.emit_intermediate(value, [value,key])


lst_relations = [] #intermediate list    
def reducer(key, list_of_values):   
    ###Reducer's main task is to count how many results are in each list_of_values per person
    
    # 1) transform into tuples the elements of the list in order to later eliminate duplicates with sets 
    #example: set(tuple(person, friend), tuple(friend, person)) = (person,friend)
    lstRelationships = []
    for i in list_of_values:
        lstRelationships.append(tuple(i))
    # 2) remove duplicates with a set:
    friendshipSet = set(lstRelationships)
    
    # 3) Find which are the the "real friends" - symmetrical friendships:
    bff = []
    for j in lstRelationships:
        if lstRelationships.count(j) > 1:
            bff.append(j)
    # 4) remove duplicates in bffs
    bffSkinny = set(bff)
    
    # 5) To get the assymetric list, remove the bff tuples from global friendship map:
    asymmmetricFrieds = list(friendshipSet ^ bffSkinny) 
    for k in asymmmetricFrieds:
        mr.emit(k)


if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)