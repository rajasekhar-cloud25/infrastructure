resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  chart            = "${path.root}/../charts/kubernetes-ingress"
  namespace        = "default"
  create_namespace = true

  values = [
    file("${path.root}/../charts/kubernetes-ingress/values.yaml")
  ]

  # Attach static EIPs to the NLB
  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-eip-allocations"
    value = join("\\,", var.nlb_eip_allocation_ids)
  }

  set {
    name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/aws-load-balancer-cross-zone-load-balancing-enabled"
    value = "true"
  }
}

data "aws_route53_zone" "main" {
  name         = var.domain_name
  private_zone = false
}

data "kubernetes_service" "nginx_ingress" {
  metadata {
    name      = "nginx-ingress-nginx-ingress-controller"
    namespace = "default"
  }
  depends_on = [helm_release.nginx_ingress]
}

data "aws_lb" "nginx" {
  name       = split("-", split(".", data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname)[0])[0]
  depends_on = [helm_release.nginx_ingress]
}

resource "aws_route53_record" "dns_records" {
  for_each = toset(var.dns_names)

  zone_id = data.aws_route53_zone.main.zone_id
  name    = "${each.value}.${var.domain_name}"
  type    = "A"

  alias {
    name                   = data.kubernetes_service.nginx_ingress.status[0].load_balancer[0].ingress[0].hostname
    zone_id                = data.aws_lb.nginx.zone_id
    evaluate_target_health = true
  }
}