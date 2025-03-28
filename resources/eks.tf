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

resource "aws_eks_node_group" "t75-eks-node_group" {
  cluster_name = aws_eks_cluster.t75-eks_cluster.name
  node_group_name = "t75-eks-node-group"
  node_role_arn   = aws_iam_role.eks_node_role.arn
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

resource "kubernetes_role" "serviceaccount_manager" {
  metadata {
    name      = "serviceaccount-manager"
    namespace = "kube-system"
  }

  rule {
    api_groups = [""]
    resources  = ["serviceaccounts"]
    verbs      = ["*"]
  }

  rule {
    api_groups = ["rbac.authorization.k8s.io"]
    resources  = ["roles", "rolebindings"]
    verbs      = ["*"]
  }
}

resource "kubernetes_role_binding" "github_actions_access" {
  metadata {
    name      = "github-actions-serviceaccount-access"
    namespace = "kube-system"
  }

  subject {
    kind      = "User"
    name      = "arn:aws:iam::025066260361:user/github-actions-user"
    api_group = "rbac.authorization.k8s.io"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = "serviceaccount-manager"
  }
}