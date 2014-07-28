import json

class MapReduce:
    def __init__(self):
        #Initializes a dict called intermediate
        self.intermediate = {}
        self.result = []

    def emit_intermediate(self, key, value):
        #Note source: http://www.tutorialspoint.com/python/dictionary_setdefault.htm
            #dict.setdefault(key, default=None)
        self.intermediate.setdefault(key, [])
        self.intermediate[key].append(value)

    def emit(self, value):
        self.result.append(value) 

    def execute(self, data, mapper, reducer):
        for line in data:
            record = json.loads(line)
            mapper(record)

        for key in self.intermediate:
            reducer(key, self.intermediate[key])

        #jenc = json.JSONEncoder(encoding='latin-1')
        jenc = json.JSONEncoder()
        for item in self.result:
            print jenc.encode(item)
