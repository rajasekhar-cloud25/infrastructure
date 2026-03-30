output "namespace_names" {
  value       = [for namespace in kubernetes_namespace_v1.namespace : namespace.metadata[0].name]
  description = "List of created namespace names"
}