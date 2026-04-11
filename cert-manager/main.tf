# resource "helm_release" "cert_manager" {
#   name             = "cert-manager"
#   chart            = "${path.module}/../charts/cert-manager"
#   namespace        = "cert-manager"
#   create_namespace = true
#
#   values = [
#     file("${path.module}/../charts/cert-manager/values.yaml")
#   ]
#
#   set {
#     name  = "serviceAccount.name"
#     value = "cert-manager-controller"
#   }
#
#   set {
#     name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
#     value = var.cert_manager_role_arn
#   }
# }

resource "helm_release" "cert_manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  version    = "v1.17.1"
  namespace  = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = "true"
  }

  set {
    name  = "serviceAccount.name"
    value = "cert-manager-controller"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = var.cert_manager_role_arn
  }

  set {
    name  = "serviceAccount.automountServiceAccountToken"
    value = "true"
  }
}


resource "kubernetes_manifest" "letsencrypt_dns" {
  manifest = {
    apiVersion = "cert-manager.io/v1"
    kind       = "ClusterIssuer"
    metadata = {
      name = "letsencrypt-dns"
    }
    spec = {
      acme = {
        email  = "devops@gmail.com"
        server = "https://acme-v02.api.letsencrypt.org/directory"

        privateKeySecretRef = {
          name = "letsencrypt-dns-key"
        }

        solvers = [
          {
            dns01 = {
              route53 = {
                region = "us-east-1"
              }
            }
          }
        ]
      }
    }
  }

  depends_on = [helm_release.cert_manager]
}

