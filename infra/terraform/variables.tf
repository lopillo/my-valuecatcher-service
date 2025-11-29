variable "image_name" {
  description = "Name of the Docker image"
  type        = string
  default     = "my-valuecatcher-service"
}

variable "image_tag" {
  description = "Tag of the Docker image built by Jenkins"
  type        = string
  default     = "latest"
}

