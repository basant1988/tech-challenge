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

## Challenge #2

We need to write code that will query the meta data of an instance within AWS and provide a json formatted output. The choice of language and implementation is up to you.
Bonus Points 

The code allows for a particular data key to be retrieved individually
Hints
·         Aws Documentation (https://docs.aws.amazon.com/)
·         Azure Documentation (https://docs.microsoft.com/en-us/azure/?product=featured)
·         Google Documentation (https://cloud.google.com/docs)

## Description/Answer



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
