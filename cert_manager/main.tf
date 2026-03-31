resource "helm_release" "cert_manager" {
  name             = "cert-manager"
  repository       = "https://charts.jetstack.io"
  chart            = "cert-manager"
  namespace        = "cert-manager"
  version          = "v1.16.0"
  timeout          = 300

  set {
    name  = "crds.enabled"
    value = "true"
  }

  # Enable IRSA for Route53 access
  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.cert_manager_role_arn
  }
}