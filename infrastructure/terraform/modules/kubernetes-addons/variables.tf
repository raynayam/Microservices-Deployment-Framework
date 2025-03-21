variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "region" {
  description = "AWS region where the cluster is deployed"
  type        = string
  default     = "us-west-2"
}

variable "enable_metrics_server" {
  description = "Enable Metrics Server add-on"
  type        = bool
  default     = false
}

variable "enable_cluster_autoscaler" {
  description = "Enable Cluster Autoscaler add-on"
  type        = bool
  default     = false
}

variable "enable_prometheus" {
  description = "Enable Prometheus monitoring"
  type        = bool
  default     = false
}

variable "enable_istio" {
  description = "Enable Istio service mesh"
  type        = bool
  default     = false
}

variable "istio_version" {
  description = "Istio version to deploy"
  type        = string
  default     = "1.18.0"
}

variable "tags" {
  description = "A map of tags to add to all resources"
  type        = map(string)
  default     = {}
} 