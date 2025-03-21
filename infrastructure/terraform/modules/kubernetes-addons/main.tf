locals {
  metrics_server_helm_config = {
    name       = "metrics-server"
    chart      = "metrics-server"
    repository = "https://kubernetes-sigs.github.io/metrics-server/"
    namespace  = "kube-system"
    values     = []
  }

  cluster_autoscaler_helm_config = {
    name       = "cluster-autoscaler"
    chart      = "cluster-autoscaler"
    repository = "https://kubernetes.github.io/autoscaler"
    namespace  = "kube-system"
    values     = [
      {
        name  = "autoDiscovery.clusterName"
        value = var.cluster_name
      },
      {
        name  = "awsRegion"
        value = var.region
      }
    ]
  }
}

resource "kubernetes_namespace" "prometheus" {
  count = var.enable_prometheus ? 1 : 0

  metadata {
    name = "prometheus"
  }
}

resource "helm_release" "metrics_server" {
  count = var.enable_metrics_server ? 1 : 0

  name       = local.metrics_server_helm_config.name
  chart      = local.metrics_server_helm_config.chart
  repository = local.metrics_server_helm_config.repository
  namespace  = local.metrics_server_helm_config.namespace

  dynamic "set" {
    for_each = local.metrics_server_helm_config.values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "helm_release" "cluster_autoscaler" {
  count = var.enable_cluster_autoscaler ? 1 : 0

  name       = local.cluster_autoscaler_helm_config.name
  chart      = local.cluster_autoscaler_helm_config.chart
  repository = local.cluster_autoscaler_helm_config.repository
  namespace  = local.cluster_autoscaler_helm_config.namespace

  dynamic "set" {
    for_each = local.cluster_autoscaler_helm_config.values
    content {
      name  = set.value.name
      value = set.value.value
    }
  }
}

resource "kubernetes_namespace" "istio_system" {
  count = var.enable_istio ? 1 : 0

  metadata {
    name = "istio-system"
  }
}

resource "helm_release" "istio_base" {
  count = var.enable_istio ? 1 : 0

  name       = "istio-base"
  chart      = "base"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = kubernetes_namespace.istio_system[0].metadata[0].name

  depends_on = [kubernetes_namespace.istio_system]
}

resource "helm_release" "istiod" {
  count = var.enable_istio ? 1 : 0

  name       = "istiod"
  chart      = "istiod"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = kubernetes_namespace.istio_system[0].metadata[0].name

  set {
    name  = "global.hub"
    value = "docker.io/istio"
  }

  set {
    name  = "global.tag"
    value = var.istio_version
  }

  depends_on = [helm_release.istio_base]
}

resource "kubernetes_namespace" "istio_ingress" {
  count = var.enable_istio ? 1 : 0

  metadata {
    name = "istio-ingress"
    labels = {
      "istio-injection" = "enabled"
    }
  }

  depends_on = [helm_release.istiod]
}

resource "helm_release" "istio_ingress" {
  count = var.enable_istio ? 1 : 0

  name       = "istio-ingress"
  chart      = "gateway"
  repository = "https://istio-release.storage.googleapis.com/charts"
  namespace  = kubernetes_namespace.istio_ingress[0].metadata[0].name

  depends_on = [kubernetes_namespace.istio_ingress]
} 