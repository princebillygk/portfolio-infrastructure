variable "azure" {
  type = object({
    client_id       = string
    client_secret   = string
    subscription_id = string
    tenant_id       = string
  })
  sensitive = true
}

variable "admin_ip" {
  type = string
}

variable "app_env" {
  type = object({
    mongodb_uri = string
    resume_obj_id = string
  })
  sensitive = true
}

variable "docker_env" {
  type = object({
    username = string
    password = string
  })
  sensitive = true
}

