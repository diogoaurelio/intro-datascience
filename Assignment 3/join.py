'''
Map Input
Each input record is a list of strings representing a tuple in the database. Each list element corresponds to a different attribute of the table

The first item (index 0) in each record is a string that identifies the table the record originates from. This field has two possible values:

"line_item" indicates that the record is a line item.
"order" indicates that the record is an order.
The second element (index 1) in each record is the order_id.

LineItem records have 17 attributes including the identifier string.

Order records have 10 elements including the identifier string.

Reduce Output
The output should be a joined record: a single list of length 27 that contains the attributes from the order record followed by the fields from the line item record. Each list element should be a string.

You can test your solution to this problem using records.json:

$ python join.py records.json
You can can compare your solution with join.json.
'''
import MapReduce
import sys

mr = MapReduce.MapReduce()


def mapper(record):    
    # key: record origin
    # value: record_id
    key = record[1]
    #Note the following groups for the same order ID all items in both tables; list_of_values will be a set of 
    ##different lists stored in a Dictionary (intermediate) per record_id;
    mr.emit_intermediate(key, record)

    
def reducer(key, list_of_values):   
    #Reducer's main task is just unite all the different lists per record_id into a list, just like in join.json
    FirstList = list_of_values[0] #Record origin will be 
    RestOfResults = list_of_values[1:] #all other values in the record besides the record_origin 
    
    for i in RestOfResults: #i is a list within the several lists in list_of_values other then the first list;
        mr.emit(FirstList + i)


if __name__ == '__main__':
  inputdata = open(sys.argv[1])
  mr.execute(inputdata, mapper, reducer)