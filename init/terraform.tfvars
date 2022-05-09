# global
region              = "eu-central-1"
domain  =    "a.runalsh.ru"
alarms_email = "1@runalsh.ru"
prefix = "runalsh"


#custer
clustername        = "epam-py-cluster"
clusternode_type   = "t3a.medium"  ## 18 pods
# clusternode_type   = "t3a.small" ## 12 pods
minnumberofnodes    = 1
maxnumberofnodes    = 2
desirednumberofnodes = 1


#instance for testing
key_name2          = "oracle"
key_name           = "keykeykey"
instance_type       = "t2.micro"

#database
db_instance_type    = "db.t3.micro"
db_instance_name    = "db"
db_name             = "wandb"
dbuser              = "pypostgres"
dbpasswd            = "pypostgres"










