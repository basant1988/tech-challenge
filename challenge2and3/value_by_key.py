import json

# sample_data = '{"id":"0001","type":"donut","name":"Cake","ppu":0.55,"batters":{"batter":{"id":"1001","type":"Regular"}},"topping":{"id":"5001","type":"None"}}'
sample_data = '{"a":{"b":{"c":"d"}}}'
print("Object: ", sample_data)
print("---------------------------")
json_str = json.loads(sample_data)

# Get value for the first occurance of the key
def get_first_value_by_key(dataobject, key):
    if key in dataobject:
        return dataobject[key]
    for key, value in dataobject.items():
        if type(value) is dict:
            data = get_first_value_by_key(value, key)
            if data is not None:
                return data

# object = {“x”:{“y”:{“z”:”a”}}} key = x/y/z value = a
def get_value_by_key_pattern(dataobject, key):
    if type(key) is str:
        return get_value_by_key_pattern(dataobject, key.split("/"))
    elif len(key) == 0:
        return dataobject
    else:
        firstkey = key[0]
        if firstkey != '' and firstkey in dataobject:
            return get_value_by_key_pattern(dataobject[firstkey], key[1:])
        else:
            return

if __name__ == "__main__":
    # key = 'batters/batter'
    key = 'a/b/c'
    print("key: ", key)
    print("---------------------------")
    print("Value: ", get_value_by_key_pattern(json_str, key))


