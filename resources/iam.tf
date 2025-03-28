# EKS Cluster Role (for the control plane)
resource "aws_iam_role" "eks_cluster_role" {
  name = "t75-eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_cluster_policy" {
  role       = aws_iam_role.eks_cluster_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

# Node Group Role (for worker nodes)
resource "aws_iam_role" "eks_node_role" {
  name = "t75-eks-node-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "eks_worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "ec2_container_registry_readonly" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

resource "aws_iam_role_policy_attachment" "eks_cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

# Service Account Role for ALB Controller
resource "aws_iam_role" "eks_serviceaccount_role" {
  name = "t75-eks-serviceaccount-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Principal = {
          AWS = "arn:aws:iam::025066260361:user/github-actions-user"
        },
        Action = [
          "sts:AssumeRole",
          "sts:TagSession"
        ]
      },
      {
        Effect = "Allow",
        Principal = {
          Federated = aws_iam_openid_connect_provider.eks_oidc.arn
        },
        Action = "sts:AssumeRoleWithWebIdentity",
        Condition = {
          StringEquals = {
            "${aws_iam_openid_connect_provider.eks_oidc.url}:sub" = "system:serviceaccount:kube-system:t75-sa-eks-ec2"
          }
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "s3_read_only" {
  role       = aws_iam_role.eks_serviceaccount_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3ReadOnlyAccess"
}

# Additional policies that might be needed
resource "aws_iam_role_policy_attachment" "eks_serviceaccount_ecr" {
  role       = aws_iam_role.eks_serviceaccount_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryPowerUser"
}

resource "aws_iam_role_policy_attachment" "eks_serviceaccount_ec2" {
  role       = aws_iam_role.eks_serviceaccount_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

resource "aws_iam_policy" "eks_full_access" {
  name        = "EKSServiceAccountFullAccess"
  description = "Full EKS access for service account"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect   = "Allow",
      Action   = "eks:*",
      Resource = "*"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "eks_describe" {
  role       = aws_iam_role.eks_serviceaccount_role.name
  policy_arn = aws_iam_policy.eks_full_access.arn
}

#resource "aws_iam_user_policy" "github_actions_assume_role" {
#  name = "GitHubActionsAssumeRole"
#  user = "github-actions-user"
#
#  policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [{
#      Effect   = "Allow",
#      Action   = "sts:AssumeRole",
#      Resource = "arn:aws:iam::025066260361:role/t75-eks-serviceaccount-role"
#    }]
#  })
#}
#
#resource "aws_iam_user_policy" "github_actions_eks_access" {
#  name = "GitHubActionsEKSAccess"
#  user = "github-actions-user"
#
#  policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [
#      {
#        Effect   = "Allow",
#        Action   = [
#          "eks:DescribeCluster",
#          "eks:ListClusters"
#        ],
#        Resource = "arn:aws:eks:us-east-1:025066260361:cluster/t75-eks-cluster"
#      }
#    ]
#  })
#}
#
#resource "aws_iam_user_policy" "github_actions_full_eks_access" {
#  name = "GitHubActionsFullEKSAccess"
#  user = "github-actions-user"
#
#  policy = jsonencode({
#    Version = "2012-10-17",
#    Statement = [
#      {
#        Effect   = "Allow",
#        Action   = "eks:*",
#        Resource = "*"
#      },
#      {
#        Effect   = "Allow",
#        Action   = "iam:PassRole",
#        Resource = "arn:aws:iam::025066260361:role/t75-eks-serviceaccount-role"
#      }
#    ]
#  })
#}

resource "aws_iam_policy" "alb_controller_policy" {
  name        = "ALBControllerPolicy"
  description = "Permissions for AWS Load Balancer Controller"
  
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect = "Allow",
        Action = [
          "ec2:DescribeAccountAttributes",
          "ec2:DescribeAddresses",
          "ec2:DescribeInternetGateways",
          "elasticloadbalancing:DescribeLoadBalancers",
          "elasticloadbalancing:DescribeTargetGroups",
          "elasticloadbalancing:DescribeListeners",
          "elasticloadbalancing:DescribeRules",
          "elasticloadbalancing:DescribeTags",
          "elasticloadbalancing:CreateLoadBalancer",
          "elasticloadbalancing:CreateTargetGroup",
          "elasticloadbalancing:DeleteTargetGroup",
          "elasticloadbalancing:ModifyTargetGroup",
          "elasticloadbalancing:ModifyTargetGroupAttributes",
          "elasticloadbalancing:DeleteLoadBalancer",
          "elasticloadbalancing:ModifyLoadBalancerAttributes",
          "elasticloadbalancing:AddTags",
          "elasticloadbalancing:RemoveTags",
          "elasticloadbalancing:ModifyListener",
          "elasticloadbalancing:AddListenerCertificates",
          "elasticloadbalancing:RemoveListenerCertificates",
          "elasticloadbalancing:ModifyRule",
          "ec2:DescribeVpcs",
          "ec2:DescribeSecurityGroups",
          "ec2:DescribeSubnets",
          "ec2:DescribeAvailabilityZones",
          "ec2:DescribeLaunchTemplateVersions",
          "cognito-idp:DescribeUserPoolClient",
          "acm:ListCertificates",
          "acm:DescribeCertificate",
          "iam:ListServerCertificates",
          "iam:GetServerCertificate",
          "waf-regional:GetWebACL",
          "waf-regional:GetWebACLForResource",
          "waf-regional:AssociateWebACL",
          "waf-regional:DisassociateWebACL",
          "wafv2:GetWebACL",
          "wafv2:GetWebACLForResource",
          "wafv2:AssociateWebACL",
          "wafv2:DisassociateWebACL",
          "shield:GetSubscriptionState",
          "shield:DescribeProtection",
          "shield:CreateProtection",
          "shield:DeleteProtection"
        ],
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "alb_controller_attach" {
  role       = aws_iam_role.eks_serviceaccount_role.name
  policy_arn = aws_iam_policy.alb_controller_policy.arn
}

resource "aws_eks_access_entry" "github_actions_user_access_entry" {
  cluster_name  = aws_eks_cluster.t75-eks_cluster.name
  principal_arn = "arn:aws:iam::025066260361:user/github-actions-user"
  type          = "STANDARD"
}

