# TECH CHALLANGE

## Challenge #1

A 3-tier environment is a common setup. Use a tool of your choosing/familiarity create these resources. Please remember we will not be judged on the outcome but more focusing on the approach, style and reproducibility.


## Description:

Created 3 Tier environment in eu-west-1 in the current scenario (Can be customized from variable) , with Autoscaling and load balancingfeature

No of Public subnets        : 3 (Web APP-for each AZ)
No of Private subnet        : 3 (Backend - for each AZ)
No of Private Subnet (DB)   : 3 (Database- for each AZ)


To Deploy the infrastructure

1. AWS CLI should be installed and configured
2. Terraform should be installed

**Steps**
git clone https://github.com/basant1988/tech-challenge.git
cd tech-challenge
terraform init
terraform plan
terraform apply

### Screenshots

**Frontend Web app**
![frontend](https://user-images.githubusercontent.com/4091250/124016649-840af600-da03-11eb-967f-2bf549e5c3cc.PNG)

**Access Internal lb deployed for backend , accessing it from web application server **

![backend](https://user-images.githubusercontent.com/4091250/124016805-a6047880-da03-11eb-96a7-e80dc34e683d.PNG)

**Acessing db server from backend server**

![dbaccess](https://user-images.githubusercontent.com/4091250/124017225-1a3f1c00-da04-11eb-9182-9457d5253c53.PNG)


## Challenge #2

We need to write code that will query the meta data of an instance within AWS and provide a json formatted output. The choice of language and implementation is up to you.
Bonus Points

The code allows for a particular data key to be retrieved individually
Hints
* Aws Documentation (https://docs.aws.amazon.com/)
* Azure Documentation (https://docs.microsoft.com/en-us/azure/?product=featured)
* Google Documentation (https://cloud.google.com/docs)

## Description/Answer

Answer for this challenge can be found in `challenge2and3` directory inside file name `get_instance_metadata.py`

Dependency : `pip3 install requests`
**To get Complete instance metadata json dump **

`python3 get_instance_metadata.py`

![metadata](https://user-images.githubusercontent.com/4091250/124013689-4062bd00-da00-11eb-849d-5687f855a0b3.PNG)

**To get Complete instance metadata json dump **
`python3 get_instance_metadata.py key-to-retrieve`

E.g. `python3 get_instance_metadata.py ami-id`
E.g. `python3 get_instance_metadata.py vpc-id`

To retrieve value of a specific key , there are multiple ways to do it
1. we can do it by using https://pypi.org/project/ec2-metadata/
2. if we want to do it in generic way then we can write a mapping of all the instance metadat key and retrive them


## Challenge #3

We have a nested object, we would like a function that you pass in the object and a key and get back the value. How this is implemented is up to you.

Example Inputs
object = {“a”:{“b”:{“c”:”d”}}}
key = a/b/c
object = {“x”:{“y”:{“z”:”a”}}}
key = x/y/z
value = a

Hints:
We would like to see some tests. A quick read to help you along the way
We would expect it in any other language apart from elixir.
A quick read to help you along the way

## Description/Answer

Answer for this challenge can be found in `challenge2and3` directory inside file name `value_by_key.py`

Some scenario validation

![key1](https://user-images.githubusercontent.com/4091250/124012104-5ff8e600-d9fe-11eb-9991-063bfe5768d7.PNG)

![key2](https://user-images.githubusercontent.com/4091250/124012154-730bb600-d9fe-11eb-8cf3-496cc795fb3e.PNG)

