variable "namespaces" {
  type = list(string)
  description = "List of Kubernetes namespaces to create"
  default = []  # Default as empty list if not provided
}
