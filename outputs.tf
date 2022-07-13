output "virtual_nodes" {
  value = zipmap(keys(aws_appmesh_virtual_node.nodes), values(aws_appmesh_virtual_node.nodes)[*].arn)
}

output "service_discovery" {
  value = zipmap(keys(aws_service_discovery_service.service_discovery), values(aws_service_discovery_service.service_discovery)[*].arn)
}
