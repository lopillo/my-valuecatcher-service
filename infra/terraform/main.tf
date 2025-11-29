terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

resource "docker_network" "vc_net" {
  name = "valuecatcher-net"
}

resource "docker_image" "valuecatcher" {
  name         = "${var.image_name}:${var.image_tag}"
  keep_locally = true
}

resource "docker_container" "valuecatcher" {
  name  = "valuecatcher-app"
  image = docker_image.valuecatcher.name

  networks_advanced {
    name = docker_network.vc_net.name
  }

  ports {
    internal = 3000
    external = 3000
  }

  restart = "unless-stopped"
}
