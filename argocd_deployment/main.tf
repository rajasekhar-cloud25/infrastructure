
terraform {
  required_providers {
    kubectl = {
      source  = "alekc/kubectl"
      version = "2.1.6"
    }
  }
}

data "http" "argocd_crds" {
  for_each = toset(local.crd_files)
  url      = each.value
}

locals {
  crd_files = [
    "https://raw.githubusercontent.com/argoproj/argo-cd/v3.3.6/manifests/crds/application-crd.yaml",
    "https://raw.githubusercontent.com/argoproj/argo-cd/v3.3.6/manifests/crds/applicationset-crd.yaml",
    "https://raw.githubusercontent.com/argoproj/argo-cd/v3.3.6/manifests/crds/appproject-crd.yaml"
  ]
}



resource "helm_release" "argocd" {
  name      = "argocd-chart"
  chart     = "${path.module}/../charts/argocd"
  version   = "9.4.17"
  namespace = "argocd"
  values = [file("${path.module}/../charts/argocd/clusterValues/values.EksDemo.yaml")]

  skip_crds         = true
  replace           = true
  force_update      = true
  wait              = true

  depends_on = [kubectl_manifest.argocd_crds]
}

resource "kubectl_manifest" "argocd_crds" {
  for_each  = toset(local.crd_files)
  yaml_body = data.http.argocd_crds[each.value].response_body

  server_side_apply = true
  force_conflicts   = true
  wait              = true
}
