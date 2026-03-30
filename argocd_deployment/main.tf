resource "helm_release" "argocd" {
  name      = "argocd-chart"
  chart     = "${path.module}/../charts/argocd"
  version   = "3.0.11"
  namespace = "argocd"
  values = [file("${path.module}/../charts/argocd/clusterValues/values.EksDemo.yaml")]
}
