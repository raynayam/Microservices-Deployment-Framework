output "metrics_server_enabled" {
  description = "Whether Metrics Server is enabled"
  value       = var.enable_metrics_server
}

output "cluster_autoscaler_enabled" {
  description = "Whether Cluster Autoscaler is enabled"
  value       = var.enable_cluster_autoscaler
}

output "prometheus_enabled" {
  description = "Whether Prometheus is enabled"
  value       = var.enable_prometheus
}

output "istio_enabled" {
  description = "Whether Istio is enabled"
  value       = var.enable_istio
}

output "istio_ingress_namespace" {
  description = "Namespace for Istio ingress gateway"
  value       = var.enable_istio ? kubernetes_namespace.istio_ingress[0].metadata[0].name : null
} 