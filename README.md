# terraform-aws-mesh
AWS mesh - service discovery

<!-- BEGIN_TF_DOCS -->
## Requirements

No requirements.

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | n/a |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [aws_appmesh_mesh.mesh](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_mesh) | resource |
| [aws_appmesh_route.routes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_route) | resource |
| [aws_appmesh_virtual_node.nodes](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_node) | resource |
| [aws_appmesh_virtual_router.routers](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_router) | resource |
| [aws_appmesh_virtual_service.services](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/appmesh_virtual_service) | resource |
| [aws_service_discovery_private_dns_namespace.namespace](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_private_dns_namespace) | resource |
| [aws_service_discovery_service.service_discovery](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/service_discovery_service) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_env"></a> [env](#input\_env) | Environment | `string` | `"dev"` | no |
| <a name="input_mesh"></a> [mesh](#input\_mesh) | Mesh name | `string` | `null` | no |
| <a name="input_namespace"></a> [namespace](#input\_namespace) | Service discovery http namespace | `string` | `null` | no |
| <a name="input_routers"></a> [routers](#input\_routers) | A list of routers | <pre>list(object({<br>    name = string<br>    route = object({<br>      spec = object({<br>        http_route = object({<br>          method = string<br>          scheme = string<br>          match = object({<br>            prefix = string<br>            header = list(object({<br>              name = string<br>              match = object({<br>                prefix = string<br>              })<br>            }))<br>          })<br>          action = object({<br>            weighted_target = list(object({<br>              virtual_node = string<br>              weight       = number<br>            }))<br>          })<br>        })<br>      })<br>    })<br>  }))</pre> | `[]` | no |
| <a name="input_services"></a> [services](#input\_services) | A list of virtual services | <pre>list(object({<br>    name    = string<br>    family  = string // family is group of same service with different versions and is used for mapping router (canary release) <br>    port    = number<br>    backend = list(string)<br>  }))</pre> | `[]` | no |
| <a name="input_vpc_id"></a> [vpc\_id](#input\_vpc\_id) | VPC ID | `any` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_service_discovery"></a> [service\_discovery](#output\_service\_discovery) | n/a |
| <a name="output_virtual_nodes"></a> [virtual\_nodes](#output\_virtual\_nodes) | n/a |
<!-- END_TF_DOCS -->