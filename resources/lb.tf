# https://github.com/kubernetes-sigs/aws-load-balancer-controller/issues/3396
resource "aws_lb" "t75-lb_ingress" {
  name = "t75-lb-ingress"
  internal = false
  load_balancer_type = "application"
  security_groups = [aws_security_group.t75-sg.id]
  subnets = [aws_subnet.t75-vpc_subnet1.id, aws_subnet.t75-vpc_subnet2.id]

  enable_deletion_protection = false

  enable_http2 = true
  enable_cross_zone_load_balancing = true

  ip_address_type = "ipv4"

  tags = {
    ManagedBy = "AWS Load Balancer Controller"
    "elbv2.k8s.aws/cluster" = aws_eks_cluster.t75-eks_cluster.name
    "ingress.k8s.aws/resource" = "LoadBalancer"
    "ingress.k8s.aws/stack" = "t75-lb-ingress"
    "kubernetes.io/cluster/t75-lb-ingress" = "owned"
  }

  lifecycle {
    ignore_changes = [security_groups]
  }
}

resource "aws_lb_target_group" "t75-lb_tg" {
  name = "t75-lb-tg"
  port = aws_lb_listener.t75-lb_listener.port
  protocol = "TCP"
  vpc_id = aws_lb.t75-lb_ingress.vpc_id
  target_type = "alb"
}

resource "aws_lb_listener" "t75-lb_listener" {
  load_balancer_arn = aws_lb.t75-lb_ingress.arn
  port = 80
  protocol = "HTTP"

  default_action {
    vehicle = 1
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      status_code = "404"
    }
  }

  tags = {
    ManagedBy = "AWS Load Balancer Controller"
    "elbv2.k8s.aws/cluster" = aws_eks_cluster.t75-eks_cluster.name
    "ingress.k8s.aws/resource" = "80"
    "ingress.k8s.aws/stack" = aws_lb.t75-lb_ingress.name
    "kubernetes.io/cluster/${aws_eks_cluster.t75-eks_cluster.name}" = "owned"
  }
}

# resource "aws_lb_listener_rule" "t75-lb_listener_role" {
#   listener_arn = aws_lb_listener.t75-lb_listener.arn
#   # priority = 10

#   action {
#     type = "forward"
#     target_group_arn = aws_lb_target_group.t75-lb_tg.arn
#   }

#   condition {
#     path_pattern {
#       values = ["/*"]
#     }
#   }
# }

resource "aws_lb_target_group_attachment" "t75-lb_attachment_listener" {
  target_group_arn = aws_lb_target_group.t75-lb_tg.arn
  target_id = aws_lb.t75-lb_ingress.arn
  port = aws_lb_listener.t75-lb_listener.port
}