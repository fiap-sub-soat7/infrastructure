resource "aws_eks_cluster" "t75-eks_cluster" {
  name = "t75-eks-cluster"
  role_arn = aws_iam_role.eks_cluster_role.arn

  vpc_config {
    subnet_ids = [aws_subnet.t75-vpc_subnet1.id, aws_subnet.t75-vpc_subnet2.id]
    security_group_ids = [aws_security_group.t75-sg.id]
    # cluster_security_group_id = aws_security_group.t75-sg.id
    endpoint_public_access = true
  }

  access_config {
    authentication_mode = "API_AND_CONFIG_MAP"
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_policy,
  ]
}

resource "aws_eks_access_policy_association" "t75-eks_access_policy" {
  cluster_name = aws_eks_cluster.t75-eks_cluster.name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${var.ACCOUNT_ID}:role/t75-eks-cluster-role"

  access_scope {
    type = "cluster"
  }

  depends_on = [aws_eks_access_entry.github_actions_user_access_entry]
}

resource "aws_eks_node_group" "t75-eks-node_group" {
  cluster_name = aws_eks_cluster.t75-eks_cluster.name
  node_group_name = "t75-eks-node-group"
  node_role_arn = "arn:aws:iam::${var.ACCOUNT_ID}:role/t75-eks-node-role"
  subnet_ids = [aws_subnet.t75-vpc_subnet1.id, aws_subnet.t75-vpc_subnet2.id]
  instance_types = ["t3.medium"]

  depends_on = [aws_eks_cluster.t75-eks_cluster]

  scaling_config {
    desired_size = 1
    max_size = 2
    min_size = 1
  }

  update_config {
    max_unavailable = 1
  }

  ami_type       = "AL2_x86_64"  # Explicit AMI type
  capacity_type  = "ON_DEMAND"   # More reliable than SPOT for initial setup
  disk_size      = 20            # Minimum recommended size

  labels = {
    role = "worker"
  }

  taint {
    key    = "dedicated"
    value  = "worker"
    effect = "NO_SCHEDULE"
  }
}

data "tls_certificate" "eks_oidc" {
  url = aws_eks_cluster.t75-eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "eks_oidc" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_oidc.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.t75-eks_cluster.identity[0].oidc[0].issuer
}