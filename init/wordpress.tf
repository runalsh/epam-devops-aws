#==== prov ======================

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
    }
  }
}

provider "aws" {
  region = var.region
}

#===== variables =================

variable "region" {
  default = "eu-central-1"
}

variable "public_subnets" {
  default = ["10.0.0.0/24", "10.0.1.0/24"]
}

variable "key_name" {
  type    = string
  default = "keykeykey"
}

variable "key_name2" {
  type    = string
  default = "oracle"
}

variable "name" {
  type    = string
  default = "epam-py-cluster"
}

variable "db_name" {
  default = "wandb"
}

variable "dbuser" {
  default = "pypostgres"
}

variable "dbpasswd" {
  default = "pypostgres"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}


#========== S3 ==============

# resource "aws_s3_bucket" "terraform_state" {
#   bucket = "statebucket-my"
#   lifecycle {
#     prevent_destroy = true
#   }
#   # versioning {
#   #   enabled = true
#   # }
# } 

terraform {
  backend "s3" {
    bucket = "statebucket-my"
    key    = "statebucket-my/terraform.tfstate"
    region = "eu-central-1"
  }
}

#====================== ECR 

resource "aws_ecr_repository" "app_repo_back_prod" {
  name = "epamapp-back-prod"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy_back_prod" {
  repository = aws_ecr_repository.app_repo_back_prod.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "more 5 to trash",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["prod","back"],
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource "aws_ecr_repository" "app_repo_front_prod" {
  name = "epamapp-front-prod"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy_front_prod" {
  repository = aws_ecr_repository.app_repo_front_prod.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "more 5 to trash",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["prod","back"],
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource "aws_ecr_repository" "app_repo_back_dev" {
  name = "epamapp-back-dev"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy_back_dev" {
  repository = aws_ecr_repository.app_repo_back_dev.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "more 5 to trash",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["prod","back"],
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

resource "aws_ecr_repository" "app_repo_front_dev" {
  name = "epamapp-front-dev"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy_front_dev" {
  repository = aws_ecr_repository.app_repo_front_dev.name

  policy = <<EOF
{
  "rules": [
    {
      "rulePriority": 1,
      "description": "more 5 to trash",
      "selection": {
        "tagStatus": "tagged",
        "tagPrefixList": ["prod","back"],
        "countType": "imageCountMoreThan",
        "countNumber": 5
      },
      "action": {
        "type": "expire"
      }
    }
  ]
}
EOF
}

#============ RES ==========

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh
}

#========== perm ============

resource "aws_iam_role" "eks-cluster" {
  name               = "eks-cluster"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-cluster-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role_policy_attachment" "eks-vpc-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.eks-cluster.name
}

resource "aws_iam_role" "eks-worker-node-iam-role" {
  name = "cluster-worker-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.eks-worker-node-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-eks-cni-policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.eks-worker-node-iam-role.name
}

resource "aws_iam_role_policy_attachment" "eks-worker-node-ec2-container-registry-readonly-policy-attachment" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.eks-worker-node-iam-role.name
}

resource "aws_iam_role_policy_attachment" "cloudwatch-logs-full-access" {
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchLogsFullAccess"
  role       = aws_iam_role.eks-worker-node-iam-role.name
}



#========== VPC =======================

resource "aws_internet_gateway" "igw_main" {
  vpc_id = aws_vpc.vpc_main.id
}

resource "aws_security_group" "sg_main" {
  name   = "aws-sec-group-main"
  vpc_id = aws_vpc.vpc_main.id


  dynamic "ingress" {
    # for_each = ["22","80","443"]
    for_each = ["22"]
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_availability_zones" "aviable_zones" {
  state = "available"
}

resource "aws_subnet" "subnets" {
  count                   = length(var.public_subnets)
  vpc_id                  = aws_vpc.vpc_main.id
  cidr_block              = var.public_subnets[count.index]
  availability_zone       = data.aws_availability_zones.aviable_zones.names[count.index]
  map_public_ip_on_launch = "true"
}

resource "aws_vpc" "vpc_main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true
}

resource "aws_route_table" "vpc_route" {
  vpc_id = aws_vpc.vpc_main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }
}

resource "aws_route_table_association" "vpc_route_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.vpc_route.id
}

resource "aws_db_subnet_group" "sub_db_sg" {
  name       = "subnet-db-sg"
  subnet_ids = [aws_subnet.subnets.0.id, aws_subnet.subnets.1.id]
}

resource "aws_security_group" "cluster_sg" {
  name   = "cluster-sg"
  vpc_id = aws_vpc.vpc_main.id

  ingress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = [aws_vpc.vpc_main.cidr_block]
      # cidr_blocks = ["0.0.0.0/0"]
      # self             = false
    }
  
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "cluster-sg"
  }
}

resource "aws_security_group" "nodes-sg" {
  name        = "nodes-sg"
  vpc_id      = aws_vpc.vpc_main.id
  
  # ingress {
  #     from_port        = 0
  #     to_port          = 0
  #     protocol         = "-1"
  #     #cidr_blocks      = [aws_vpc.vpc_main.cidr_block]
  #     cidr_blocks = ["0.0.0.0/0"]
  #     # self             = false
  #   }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = "node-cluster-sg"
  }
}  
#====DB=============
resource "aws_db_instance" "db" {
  identifier = "db"
  engine = "postgres"
  engine_version = "13.4"
  allocated_storage = 5
  instance_class = "db.t3.micro"
  vpc_security_group_ids = [aws_security_group.db_sg.id ]
  availability_zone = "eu-central-1a" 
  db_subnet_group_name = aws_db_subnet_group.sub_db_sg.id
  db_name = var.db_name
  username = var.dbuser
  # password = data.aws_ssm_parameter.rds-pass.value
  password = var.dbpasswd
  publicly_accessible = true
  skip_final_snapshot = true
  tags = {
    Name = "postgresql"
  }
}

#========RDS==============================

resource "random_string" "rds_password" {
  length           = 15
  special          = true
  override_special = "!#&"
  # keepers = {
  # kepeer1 = var.db_password
  # } 
}

resource "aws_ssm_parameter" "rds_password" {
  name  = "rds-ssm"
  type  = "SecureString"
  value = random_string.rds_password.result
}

data "aws_ssm_parameter" "rds-pass" {
  name       = "rds-ssm"
  depends_on = [aws_ssm_parameter.rds_password]
}

#==========DB sg========================
resource "aws_security_group" "db_sg" {
  name   = "db_sg"
  vpc_id = aws_vpc.vpc_main.id

  ingress = [
    {
      description      = "allow to db connect outside"
      from_port        = 5432
      to_port          = 5432
      protocol         = "tcp"
      cidr_blocks      = [aws_vpc.vpc_main.cidr_block]
      # cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]

  egress = [
    {
      description      = "allow out connections from db"
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = [aws_vpc.vpc_main.cidr_block]
      # cidr_blocks = ["0.0.0.0/0"]
      ipv6_cidr_blocks = []
      prefix_list_ids  = []
      security_groups  = []
      self             = false
    }
  ]
}

resource "aws_cloudwatch_log_group" "eks-logs" {
  name              = "/aws/eks/epam-py-cluster/"
  retention_in_days = 1
}

resource "aws_cloudwatch_dashboard" "eks-cluster-application" {
  dashboard_name = "eks-cluster-application"
  dashboard_body = <<EOF

{
    "widgets": [
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 0,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "id": "expr1m0", "label": "epam-py-cluster", "expression": "mm1m0 * 100 / mm0m0", "region": "eu-central-1" } ],
                    [ "ContainerInsights", "node_cpu_limit", "ClusterName", "epam-py-cluster", { "period": 300, "stat": "Sum", "id": "mm0m0", "visible": false, "region": "eu-central-1" } ],
                    [ "ContainerInsights", "node_cpu_usage_total", "ClusterName", "epam-py-cluster", { "period": 300, "stat": "Sum", "id": "mm1m0", "visible": false, "region": "eu-central-1" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "CPU Utilization",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "timeSeries",
                "stacked": true,
                "period": 300
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 6,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ { "id": "expr1m0", "label": "epam-py-cluster", "expression": "mm1m0 * 100 / mm0m0" } ],
                    [ "ContainerInsights", "node_memory_limit", "ClusterName", "epam-py-cluster", { "period": 300, "stat": "Sum", "id": "mm0m0", "visible": false } ],
                    [ "ContainerInsights", "node_memory_working_set", "ClusterName", "epam-py-cluster", { "period": 300, "stat": "Sum", "id": "mm1m0", "visible": false } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "MemoryUtilization",
                "yAxis": {
                    "left": {
                        "min": 0,
                        "showUnits": false,
                        "label": "Percent"
                    }
                },
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "timeSeries",
                "stacked": true
            }
        },
        {
            "height": 6,
            "width": 6,
            "y": 0,
            "x": 12,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ContainerInsights", "node_network_total_bytes", "ClusterName", "epam-py-cluster", { "period": 300, "stat": "Average" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "Network",
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "timeSeries",
                "stacked": true
            }
        },
        {
            "height": 3,
            "width": 6,
            "y": 0,
            "x": 18,
            "type": "metric",
            "properties": {
                "metrics": [
                    [ "ContainerInsights", "cluster_node_count", "ClusterName", "epam-py-cluster", { "period": 300, "stat": "Average" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "title": "EKS:Clusters.NumberOfNodes",
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "view": "singleValue",
                "stacked": false
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 12,
            "x": 12,
            "type": "metric",
            "properties": {
                "region": "eu-central-1",
                "title": "Pods Network",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ { "id": "expr0m0", "label": "prod epamapp-back-prod pod_network_rx_bytes", "expression": "mm0m0 + mm0farm0", "stat": "Average", "yAxis": "left" } ],
                    [ { "id": "expr0m1", "label": "prod epamapp-front-prod pod_network_rx_bytes", "expression": "mm0m1 + mm0farm1", "stat": "Average", "yAxis": "left" } ],
                    [ "ContainerInsights", "pod_network_rx_bytes", "PodName", "epamapp-back-prod", "Namespace", "prod", "ClusterName", "epam-py-cluster", { "id": "mm0m0", "visible": false, "yAxis": "left" } ],
                    [ "ContainerInsights", "pod_network_rx_bytes", "PodName", "epamapp-front-prod", "Namespace", "prod", "ClusterName", "epam-py-cluster", { "id": "mm0m1", "visible": false, "yAxis": "left" } ],
                    [ "ContainerInsights", "pod_network_rx_bytes", "ClusterName", "epam-py-cluster", "PodName", "epamapp-back-prod", "Namespace", "prod", "LaunchType", "fargate", { "id": "mm0farm0", "visible": false, "yAxis": "left" } ],
                    [ "ContainerInsights", "pod_network_rx_bytes", "ClusterName", "epam-py-cluster", "PodName", "epamapp-front-prod", "Namespace", "prod", "LaunchType", "fargate", { "id": "mm0farm1", "visible": false, "yAxis": "left" } ],
                    [ { "id": "expr1m0", "label": "prod epamapp-back-prod pod_network_tx_bytes", "expression": "mm1m0 + mm1farm0", "stat": "Average", "yAxis": "right" } ],
                    [ { "id": "expr1m1", "label": "prod epamapp-front-prod pod_network_tx_bytes", "expression": "mm1m1 + mm1farm1", "stat": "Average", "yAxis": "right" } ],
                    [ "ContainerInsights", "pod_network_tx_bytes", "PodName", "epamapp-back-prod", "Namespace", "prod", "ClusterName", "epam-py-cluster", { "id": "mm1m0", "visible": false, "yAxis": "right" } ],
                    [ "ContainerInsights", "pod_network_tx_bytes", "PodName", "epamapp-front-prod", "Namespace", "prod", "ClusterName", "epam-py-cluster", { "id": "mm1m1", "visible": false, "yAxis": "right" } ],
                    [ "ContainerInsights", "pod_network_tx_bytes", "ClusterName", "epam-py-cluster", "PodName", "epamapp-back-prod", "Namespace", "prod", "LaunchType", "fargate", { "id": "mm1farm0", "visible": false, "yAxis": "right" } ],
                    [ "ContainerInsights", "pod_network_tx_bytes", "ClusterName", "epam-py-cluster", "PodName", "epamapp-front-prod", "Namespace", "prod", "LaunchType", "fargate", { "id": "mm1farm1", "visible": false, "yAxis": "right" } ]
                ],
                "start": "-P0DT1H0M0S",
                "end": "P0D",
                "liveData": false,
                "period": 60,
                "view": "timeSeries",
                "stacked": false
            }
        },
        {
            "height": 3,
            "width": 6,
            "y": 3,
            "x": 18,
            "type": "metric",
            "properties": {
                "region": "eu-central-1",
                "title": "Number of Pods",
                "legend": {
                    "position": "bottom"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ContainerInsights", "node_number_of_running_pods", "InstanceId", "i-041c900efac984628", "NodeName", "ip-10-0-0-164.eu-central-1.compute.internal", "ClusterName", "epam-py-cluster", { "stat": "Average" } ]
                ],
                "start": "-P0DT1H0M0S",
                "end": "P0D",
                "liveData": false,
                "period": 60,
                "view": "singleValue",
                "stacked": false
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 6,
            "x": 0,
            "type": "metric",
            "properties": {
                "region": "eu-central-1",
                "title": "Node CPU Utilization",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ContainerInsights", "pod_cpu_utilization", "PodName", "epamapp-front-prod", "Namespace", "prod", "ClusterName", "epam-py-cluster", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_cpu_utilization", "PodName", "epamapp-back-prod", "Namespace", "prod", "ClusterName", "epam-py-cluster", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_cpu_utilization", "PodName", "epamapp-front-dev", "Namespace", "dev", "ClusterName", "epam-py-cluster", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_cpu_utilization", "PodName", "epamapp-back-dev", "Namespace", "dev", "ClusterName", "epam-py-cluster", { "stat": "Average" } ]
                ],
                "start": "-P0DT1H0M0S",
                "end": "P0D",
                "liveData": false,
                "period": 60,
                "view": "timeSeries",
                "stacked": false
            }
        },
        {
            "height": 6,
            "width": 12,
            "y": 6,
            "x": 12,
            "type": "metric",
            "properties": {
                "region": "eu-central-1",
                "title": "Node Memory Utilization",
                "legend": {
                    "position": "right"
                },
                "timezone": "Local",
                "metrics": [
                    [ "ContainerInsights", "pod_memory_utilization", "PodName", "epamapp-back-prod", "Namespace", "prod", "ClusterName", "epam-py-cluster", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_memory_utilization", "PodName", "epamapp-front-prod", "Namespace", "prod", "ClusterName", "epam-py-cluster", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_memory_utilization", "PodName", "epamapp-front-dev", "Namespace", "dev", "ClusterName", "epam-py-cluster", { "stat": "Average" } ],
                    [ "ContainerInsights", "pod_memory_utilization", "PodName", "epamapp-back-dev", "Namespace", "dev", "ClusterName", "epam-py-cluster", { "stat": "Average" } ]
                ],
                "start": "-P0DT1H0M0S",
                "end": "P0D",
                "liveData": false,
                "period": 60,
                "view": "timeSeries",
                "stacked": false
            }
        },
        {
            "type": "metric",
            "x": 0,
            "y": 12,
            "width": 6,
            "height": 3,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "DatabaseConnections", "DBInstanceIdentifier", "db", { "period": 300, "stat": "Sum" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "title": "DatabaseConnections: Sum",
                "view": "singleValue",
                "stacked": false
            }
        },
        {
            "type": "metric",
            "x": 6,
            "y": 12,
            "width": 6,
            "height": 6,
            "properties": {
                "metrics": [
                    [ "AWS/RDS", "FreeableMemory", "DBInstanceIdentifier", "db", { "period": 300, "stat": "Average" } ]
                ],
                "legend": {
                    "position": "bottom"
                },
                "region": "eu-central-1",
                "liveData": false,
                "start": "-PT1H",
                "end": "PT0H",
                "title": "Database FreeableMemory: Average",
                "view": "timeSeries",
                "stacked": true
            }
        }
    ]
}

EOF
}


##=============================EKS

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.name
  role_arn = aws_iam_role.eks-cluster.arn
  version    = "1.22"
  enabled_cluster_log_types = ["api", "audit", "authenticator", "controllerManager", "scheduler"]

  vpc_config {
    # endpoint_private_access = true
    # endpoint_public_access  = true
    security_group_ids = [aws_security_group.cluster_sg.id]
    subnet_ids = aws_subnet.subnets[*].id
  }
  depends_on = [
     aws_iam_role_policy_attachment.eks-cluster-policy,
     aws_iam_role_policy_attachment.eks-vpc-policy,
     aws_cloudwatch_log_group.eks-logs
  ]
}

resource "aws_eks_node_group" "nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  node_group_name = "nodes"
  node_role_arn   = aws_iam_role.eks-worker-node-iam-role.arn
  subnet_ids      = aws_subnet.subnets[*].id
  scaling_config {
    desired_size = 1
    max_size     = 2
    min_size     = 1
  }

#    remote_access {
#      ec2_ssh_key = var.key_name2
#     source_security_group_ids = [aws_security_group.sg_main.id]
#    }

  disk_size            = 8
  # capacity_type        = "ON_DEMAND"
  capacity_type        = "SPOT"
  force_update_version = false
  instance_types       = ["t3.small"]
  ###  you must choose instance with > = 12 pods https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
  labels               = {
    role = "nodes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-policy,
    aws_iam_role_policy_attachment.eks-worker-node-eks-cni-policy,
    aws_iam_role_policy_attachment.eks-worker-node-ec2-container-registry-readonly-policy-attachment,
    aws_iam_role_policy_attachment.cloudwatch-logs-full-access
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
}


# #=========  not scale ======================
# resource "aws_instance" "wp_instance" {
# ami                     = "ami-0ca64d1b4e674f837"
# instance_type           = "t2.micro"
# subnet_id      = aws_subnet.subnets.0.id
# vpc_security_group_ids  = [aws_security_group.sg_main.id]
# key_name                = var.key_name2
# lifecycle {
# create_before_destroy = true
# }
# }  




# #================SHOWMEWHATYOUHAVE===================
# output "rds_hostname_address" {
#   description = "RDS instance hostname"
#   value       = aws_db_instance.db.address
#   sensitive   = false
# }

# output "cluster_endpoint" {
#   description = "cluster endpoint"
#   value = aws_eks_cluster.eks_cluster.endpoint
# }

# output "kubeconfig_certificate_authority_data" {
#   description = "kube certificate"
#   value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
#   sensitive   = false
# }