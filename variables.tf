variable "env" {
  description = "Environment"
  default     = "dev"
}

variable "vpc_id" {
  description = "VPC ID"
}

variable "mesh" {
  description = "Mesh name"
  type        = string
  default     = null
}

variable "namespace" {
  description = "Service discovery http namespace"
  type        = string
  default     = null
}

variable "services" {
  description = "A list of virtual services"
  type = list(object({
    name    = string
    family  = string // family is group of same service with different versions and is used for mapping router (canary release) 
    port    = number
    backend = list(string)
  }))
  default = []
}

variable "routers" {
  description = "A list of routers"
  type = list(object({
    name = string
    route = object({
      spec = object({
        http_route = object({
          method = string
          scheme = string
          match = object({
            prefix = string
            header = list(object({
              name = string
              match = object({
                prefix = string
              })
            }))
          })
          action = object({
            weighted_target = list(object({
              virtual_node = string
              weight       = number
            }))
          })
        })
      })
    })
  }))
  default = []
}
