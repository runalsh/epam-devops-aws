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



#========== S3 ==============

resource "aws_s3_bucket" "terraform_state" {
   bucket = "statebucket-myy"
   lifecycle {
     prevent_destroy = true
   }
    versioning {
      enabled = true
    }
 } 

terraform {
  backend "s3" {
    bucket = "statebucket-myy"
    key    = "statebucket-myy/terraform.tfstate"
    region = "eu-central-1"
  }
}

#====================== ECR 

resource "aws_ecr_repository" "app_repo_back_prod" {
  name = "epamapp-back-prod"

  image_scanning_configuration {
    scan_on_push = true
  }
}

locals {
    aws_ecr_lifecycle_policy = <<EOF
{
    "rules": [
        {
            "rulePriority": 1,
            "description": "Keep last 3 images",
            "selection": {
                "tagStatus": "any",
                "countType": "imageCountMoreThan",
                "countNumber": 3
            },
            "action": {
                "type": "expire"
            }
        }
    ]
}
EOF
}

resource "aws_ecr_lifecycle_policy" "repo_policy_back_prod" {
  repository = aws_ecr_repository.app_repo_back_prod.name

  policy = local.aws_ecr_lifecycle_policy
}


resource "aws_ecr_repository" "app_repo_front_prod" {
  name = "epamapp-front-prod"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy_front_prod" {
  repository = aws_ecr_repository.app_repo_front_prod.name

  policy  = local.aws_ecr_lifecycle_policy
}

resource "aws_ecr_repository" "app_repo_back_dev" {
  name = "epamapp-back-dev"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy_back_dev" {
  repository = aws_ecr_repository.app_repo_back_dev.name

   policy = local.aws_ecr_lifecycle_policy
}

resource "aws_ecr_repository" "app_repo_front_dev" {
  name = "epamapp-front-dev"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "repo_policy_front_dev" {
  repository = aws_ecr_repository.app_repo_front_dev.name

   policy = local.aws_ecr_lifecycle_policy
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
  name               = var.clustername
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
  name = "${var.prefix}-cluster-worker-node"

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
  tags = {
    name = "${var.prefix}-main-igw"
  }
}

resource "aws_security_group" "sg_main" {
  name   = "${var.prefix}-aws-sec-group-main"
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
  tags = {
    name = "${var.prefix}-main-sec-group"
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

  tags = {
    name = "${var.prefix}-subnets-vpcmain"
  }
}

resource "aws_vpc" "vpc_main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = {
    name = "${var.prefix}-vpcmain"
  }
}

resource "aws_route_table" "vpc_route" {
  vpc_id = aws_vpc.vpc_main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw_main.id
  }
  tags = {
    name = "${var.prefix}-vpc-route"
  }
}

resource "aws_route_table_association" "vpc_route_assoc" {
  count          = length(var.public_subnets)
  subnet_id      = aws_subnet.subnets[count.index].id
  route_table_id = aws_route_table.vpc_route.id
}

resource "aws_db_subnet_group" "sub_db_sg" {
  name       = "${var.prefix}-subnet-db-sg"
  subnet_ids = [aws_subnet.subnets.0.id, aws_subnet.subnets.1.id]
  tags = {
    name = "${var.prefix}-db-subnet-group"
  }
}

resource "aws_security_group" "cluster_sg" {
  name   = "${var.prefix}-cluster-sg"
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
    name = "${var.prefix}-cluster-sg"
  }
}

resource "aws_security_group" "nodes-sg" {
  name        = "${var.prefix}-nodes-sg"
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
    Name = "${var.prefix}-node-cluster-sg"
  }
}  
#====DB=============

resource "aws_db_instance" "db" {
  identifier = var.db_instance_name
  engine = "postgres"
  engine_version = "13.4"
  allocated_storage = 5
  instance_class = var.db_instance_type
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
    name = "${var.prefix}-postgresql"
  }
}

###========RDS==============================

resource "random_string" "rds_password" {
  length           = 15
  special          = true
  override_special = "!#&"
  # keepers = {
  # kepeer1 = var.db_password
  # } 
}

resource "aws_ssm_parameter" "rds_password" {
  name  = "${var.prefix}-rds-ssm"
  type  = "SecureString"
  value = random_string.rds_password.result
}

data "aws_ssm_parameter" "rds-pass" {
  name       = "${var.prefix}-rds-ssm"
  depends_on = [aws_ssm_parameter.rds_password]
}

###==========DB sg========================

resource "aws_security_group" "db_sg" {
  name   = "${var.prefix}-db_sg"
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
  tags = {
    name = "${var.prefix}-db-sec-group"
  }
}

### =======================c  cloudwatch

resource "aws_cloudwatch_log_group" "eks-logs" {
  name              = "/aws/eks/${var.clustername}/"
  retention_in_days = 3
}

resource "aws_cloudwatch_log_stream" "eks-logs-stream" {
 name           = "${var.clustername}-logs-stream"
 log_group_name = "${aws_cloudwatch_log_group.eks-logs.name}"
}

resource "aws_cloudwatch_metric_alarm" "cpu_high" {
  alarm_name          = "cpu_utilization_high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "30"
  statistic           = "Average"
  threshold           = "80"

  dimensions = {
    ClusterName = "${aws_eks_cluster.eks_cluster.name}"
  }

  alarm_actions = ["${aws_sns_topic.alarm.arn}"]
}

resource "aws_sns_topic" "alarm" {
  name            = "${var.prefix}-alarms"
  delivery_policy = <<EOF
  {
  "http": {
    "defaultHealthyRetryPolicy": {
      "minDelayTarget": 20,
      "maxDelayTarget": 20,
      "numRetries": 3,
      "numMaxDelayRetries": 0,
      "numNoDelayRetries": 0,
      "numMinDelayRetries": 0,
      "backoffFunction": "linear"
    },
    "disableSubscriptionOverrides": false,
    "defaultThrottlePolicy": {
      "maxReceivesPerSecond": 1
      }
    }
  }
  EOF

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${self.arn} --protocol email --notification-endpoint ${var.alarms_email}"
  }
}


#command = "curl https://api.telegram.org/bot${local.TOKEN}/sendMessage?text="ALARMALARMALARM"&chat_id=${local.ID}


# data "aws_secretsmanager_secret" "telegram" {
#   name = "telegramtokenid"
# }
# data "aws_secretsmanager_secret_version" "telegram" {
#   secret_id = data.aws_secretsmanager_secret.telegram.id
# }
# locals {
#   TOKEN = jsondecode(data.aws_secretsmanager_secret_version.telegram.secret_string)["TOKEN"]
#   ID = jsondecode(data.aws_secretsmanager_secret_version.telegram.secret_string)["ID"]      
# }


  # environment = {
  #     TOKEN = var.telegramtoken
  #   }
# - name: Setup Terraform variables
#             working-directory: 
#             id: vars
#             run: |
#               export telegramtoken = "${{ secrets.TELEGRAMTOKEN }}"






##=============================EKS

resource "aws_eks_cluster" "eks_cluster" {
  name     = var.clustername
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
    desired_size = var.desirednumberofnodes
    max_size     = var.maxnumberofnodes
    min_size     = var.minnumberofnodes
  }

#    remote_access {
#      ec2_ssh_key = var.key_name2
#     source_security_group_ids = [aws_security_group.sg_main.id]
#    }

  disk_size            = 8
  # capacity_type        = "ON_DEMAND"
  capacity_type        = "SPOT"
  force_update_version = false
  instance_types       = [var.clusternode_type]
  ###  you must choose instance with > = 12 pods https://github.com/awslabs/amazon-eks-ami/blob/master/files/eni-max-pods.txt
  labels               = {
    role = "nodes"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks-worker-node-policy,
    aws_iam_role_policy_attachment.eks-worker-node-eks-cni-policy,
    aws_iam_role_policy_attachment.eks-worker-node-ec2-container-registry-readonly-policy-attachment,
    aws_iam_role_policy_attachment.cloudwatch-logs-full-access
    aws_iam_role_policy_attachment.route53_modify_policy
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks_cluster.endpoint
  token                  = data.aws_eks_cluster_auth.eks_cluster.token
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks_cluster.certificate_authority.0.data)
}


#=========  RUNNER  ======================
# resource "aws_instance" "instance" {
# ami                     = "ami-0ca64d1b4e674f837"
# instance_type           = "t2.micro"
# subnet_id      = aws_subnet.subnets.0.id
# vpc_security_group_ids  = [aws_security_group.sg_main.id]
# key_name                = var.key_name2

# user_data = data.template_cloudinit_config.cloudinit_config.rendered

# lifecycle {
# create_before_destroy = true
# }
# }  

# data "template_file" "cloudinit_main" {
#   template = file("./ci.yml")
# }

# data "template_cloudinit_config" "cloudinit_config" {
#   gzip          = false
#   base64_encode = false
#   part {
#     filename     = "./ci.yml"
#     content_type = "text/cloud-config"
#     content      = data.template_file.cloudinit_main.rendered
#   }
# }

##  =========================== S53

resource "aws_route53_zone" "primary" {
  name = "${var.domain}"
}


resource "aws_iam_role_policy_attachment" "route53_modify_policy" {
  policy_arn = aws_iam_policy.route53_modify_policy.arn
  role       = aws_iam_role.eks-worker-node-iam-role.name
}

resource "aws_iam_policy" "route53_modify_policy" {
  name        = "${var.prefix}-route53_modify_policy"
  path        = "/"
  description = "This policy allows route53 modifications"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "route53:ChangeResourceRecordSets"
      ],
      "Resource": [
        "arn:aws:route53:::hostedzone/*"
      ]
    },
    {
      "Effect": "Allow",
      "Action": [
        "route53:ListHostedZones",
        "route53:ListResourceRecordSets"
      ],
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

# resource "aws_route53_record" "load_balancer_record" {
#   name    = "alb.${var.domain}"
#   type    = "A"
#   zone_id = "${data.aws_route53_zone.selectedzone.zone_id}"

#   alias {
#     evaluate_target_health  = false
#     name                    = "${aws_alb.cluster_alb.dns_name}"
#     zone_id                 = "${aws_alb.cluster_alb.zone_id}"
#   }
# }

## ====================  ALB

# resource "aws_security_group" "alb_security_group" {
#   name        = "${var.clustername}-alb-sq"
#   vpc_id      = "${aws_vpc.vpc_main.id}"

#   ingress {
#     from_port   = 80
#     protocol    = "TCP"
#     to_port     = 80
#     cidr_blocks = [aws_vpc.vpc_main.cidr_block]
#   }

#   egress {
#     from_port   = 0
#     protocol    = "-1"
#     to_port     = 0
#     cidr_blocks = [aws_vpc.vpc_main.cidr_block]
#   }
# }

# resource "aws_alb" "cluster_alb" {
#   name            = "${var.clustername}-alb"
#   internal        = false
#   security_groups = ["${aws_security_group.alb_security_group.id}"]
#   subnets         = aws_subnet.subnets[*].id
# }

# resource "aws_alb_listener" "alb_listener" {
#   load_balancer_arn = "${aws_alb.cluster_alb.arn}"
#   port              = "80"
#   protocol          = "HTTP"
  
#   default_action {
#     type              = "forward"
#     target_group_arn  = "${aws_alb_target_group.target_group.arn}"
#   }

#   depends_on = ["aws_alb_target_group.target_group"]
# }

# resource "aws_alb_target_group" "target_group" {
#   name        = "${var.clustername}-targetgroup"
#   port        = 80
#   protocol    = "HTTP"
#   vpc_id      = "${aws_vpc.vpc_main.id}"
#   target_type = "ip"

#   health_check {
#     healthy_threshold   = "3"
#     interval            = "30"
#     protocol            = "HTTP"
#     matcher             = "200"
#     timeout             = "3"
#     path                = "/"
#     unhealthy_threshold = "2"
#   }
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
    #sensitive   = false
# }

# output "kubeconfig_certificate_authority_data" {
#   description = "kube certificate"
#   value = aws_eks_cluster.eks_cluster.certificate_authority[0].data
#   sensitive   = false
# }