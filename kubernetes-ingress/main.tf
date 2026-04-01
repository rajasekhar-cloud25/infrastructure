resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  chart            = "${path.module}/../charts/kubernetes-ingress"
  namespace        = "default"
  create_namespace = true

  values = [
    file("${path.module}/../charts/kubernetes-ingress/values.yaml")
  ]

  # Attach static EIPs to the NLB
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-eip-allocations"
    value = join("\\,", var.nlb_eip_allocation_ids)
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-subnets"
    value = join("\\,", var.public_subnet_ids)
    type  = "string"
  }
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-cert"
    value = var.acm_certificate_arn
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-ssl-ports"
    value = "443"
    type  = "string"
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-backend-protocol"
    value = "tcp"
    type  = "string"
  }
}

data "aws_eip" "nlb" {
  count = length(var.nlb_eip_allocation_ids)
  id    = var.nlb_eip_allocation_ids[count.index]
}

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

resource "aws_route53_record" "dns_records" {
  for_each = toset(var.dns_names)

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${each.value}.${var.domain_name}"
  type    = "A"
  ttl     = 300
  records = [data.aws_eip.nlb[0].public_ip]
  depends_on = [helm_release.nginx_ingress]
}