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
    aws_iam_role_policy_attachment.eks_service_policy
  ]
}

resource "aws_eks_access_policy_association" "t75-eks_access_policy" {
  cluster_name = aws_eks_cluster.t75-eks_cluster.name
  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = "arn:aws:iam::${var.ACCOUNT_ID}:role/voclabs"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_node_group" "t75-eks-node_group" {
  cluster_name = aws_eks_cluster.t75-eks_cluster.name
  node_group_name = "t75-eks-node-group"
  node_role_arn = "arn:aws:iam::${var.ACCOUNT_ID}:role/root"
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
}

resource "aws_eks_access_entry" "t75-eks_access_entry" {
  cluster_name = aws_eks_cluster.t75-eks_cluster.name
  principal_arn = "arn:aws:iam::${var.ACCOUNT_ID}:role/voclabs"
  kubernetes_groups = [aws_eks_node_group.t75-eks-node_group.cluster_name]
  type = "STANDARD"
}


# resource "aws_eks_identity_provider_config" "t75-eks-oidc-config" {
#   cluster_name = aws_eks_cluster.t75-eks_cluster.name
#   oidc {
#     client_id = "sts.amazonaws.com"
#     identity_provider_config_name = "t75-eks-oidc"
#     issuer_url = aws_eks_cluster.t75-eks_cluster.identity[0].oidc[0].issuer
#   }
# }

# resource "aws_eks_pod_identity_association" "t75-eks_pod_role" {
#   role_arn = "arn:aws:iam::${var.ACCOUNT_ID}:role/eks-service-account-role"
#   namespace = "kube-system"
#   service_account = "t75-sa-eks-ec2"
#   cluster_name = aws_eks_cluster.t75-eks_cluster.name 
  
#   # depends_on = [kubernetes_service_account.t75-sa_eks_ec2]
# }

# resource "kubernetes_service_account" "t75-sa_eks_ec2" {
#   metadata {
#     name = "t75-sa-eks-ec2"
#     namespace = "kube-system"
#     annotations = {
#       "eks.amazonaws.com/role-arn" = "arn:aws:iam::${var.ACCOUNT_ID}:role/eks-service-account-role"
#     }
#   }
# }

# resource "aws_eks_addon" "t75-eks_pod_identity" {
#   cluster_name = aws_eks_cluster.t75-eks_cluster.name
#   addon_name = "eks-pod-identity-webhook"
# }