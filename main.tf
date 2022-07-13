locals {
  services = { for service in var.services : service.name => service }
}

resource "aws_service_discovery_private_dns_namespace" "namespace" {
  name        = "${var.namespace}.${var.env}"
  description = "private namespace"
  vpc         = var.vpc_id
}

resource "aws_service_discovery_service" "service_discovery" {
  for_each = local.services
  name     = each.key

  dns_config {
    namespace_id = aws_service_discovery_private_dns_namespace.namespace.id

    dns_records {
      ttl  = 10
      type = "A"
    }

    routing_policy = "MULTIVALUE"
  }

  health_check_custom_config {
    failure_threshold = 1
  }
  depends_on = [
    aws_service_discovery_private_dns_namespace.namespace
  ]
}

resource "aws_appmesh_mesh" "mesh" {
  name = var.mesh

  spec {
    egress_filter {
      type = "ALLOW_ALL"
    }
  }
}

resource "aws_appmesh_virtual_node" "nodes" {
  for_each  = local.services
  name      = each.value.name
  mesh_name = aws_appmesh_mesh.mesh.id

  spec {
    dynamic "backend" {
      for_each = each.value.backend
      content {
        virtual_service {
          virtual_service_name = "${backend.value}.${aws_service_discovery_private_dns_namespace.namespace.name}"
        }
      }
    }

    listener {
      port_mapping {
        port     = each.value.port
        protocol = "http"
      }
    }

    service_discovery {
      aws_cloud_map {
        service_name   = each.key
        namespace_name = aws_service_discovery_private_dns_namespace.namespace.name
      }
    }
  }
}

resource "aws_appmesh_virtual_router" "routers" {
  for_each  = { for router in var.routers : router.name => router }
  name      = each.key
  mesh_name = aws_appmesh_mesh.mesh.id

  spec {
    listener {
      port_mapping {
        port     = lookup(local.services, each.key).port
        protocol = "http"
      }
    }
  }
  depends_on = [
    aws_appmesh_virtual_node.nodes
  ]
}

resource "aws_appmesh_route" "routes" {
  for_each            = { for router in var.routers : router.name => router }
  name                = "${each.key}-route"
  mesh_name           = aws_appmesh_mesh.mesh.id
  virtual_router_name = lookup(aws_appmesh_virtual_router.routers, each.key).name
  spec {
    http_route {
      match {
        prefix = each.value.route.spec.http_route.match.prefix
        dynamic "header" {
          for_each = each.value.route.spec.http_route.match.header
          content {
            name = header.value.name
            match {
              prefix = header.value.match.prefix
            }
          }
        }
      }
      action {
        dynamic "weighted_target" {
          for_each = each.value.route.spec.http_route.action.weighted_target
          content {
            virtual_node = lookup(aws_appmesh_virtual_node.nodes, weighted_target.value.virtual_node).name
            weight       = each.value.route.spec.http_route.action.weighted_target.weight
          }
        }
      }
    }
  }
  depends_on = [
    aws_appmesh_virtual_node.nodes,
    aws_appmesh_virtual_router.routers
  ]
}

resource "aws_appmesh_virtual_service" "services" {
  for_each  = local.services
  name      = each.key
  mesh_name = aws_appmesh_mesh.mesh.id
  spec {
    provider {
      dynamic "virtual_router" {
        for_each = lookup(aws_appmesh_virtual_router.routers, each.value.family, null) != null ? [each.key] : []
        content {
          virtual_router_name = lookup(aws_appmesh_virtual_router.routers, each.value.family).name
        }
      }
      dynamic "virtual_node" {
        for_each = lookup(aws_appmesh_virtual_router.routers, each.value.family, null) == null ? [each.key] : []
        content {
          virtual_node_name = lookup(aws_appmesh_virtual_node.nodes, each.key).name
        }
      }
    }
  }
  depends_on = [
    aws_appmesh_virtual_router.routers,
    aws_appmesh_virtual_node.nodes
  ]
}

