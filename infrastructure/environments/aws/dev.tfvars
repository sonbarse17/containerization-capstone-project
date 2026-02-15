environment             = "dev"
region                  = "us-east-1"
vpc_cidr                = "10.1.0.0/16"
node_group_desired_size = 1
node_group_min_size     = 1
node_group_max_size     = 2
instance_types          = ["t3.medium"]
cluster_version         = "1.30"
