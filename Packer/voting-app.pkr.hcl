packer {
  required_version = ">= 1.10.0"

  required_plugins {
    docker = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/docker"
    }

    ansible = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/ansible"
    }
  }
}

variable "image_name" {
  type        = string
  description = "Nom de l'image Docker produite par Packer."
  default     = "voting-app-ansible"
}

variable "image_tag" {
  type        = string
  description = "Tag de l'image Docker produite par Packer."
  default     = "latest"
}

source "docker" "voting_app" {
  image  = "ubuntu:22.04"
  commit = true

  # Python est installé avant l'exécution d'Ansible, car les modules Ansible
  # comme apt, pip et copy nécessitent un interpréteur Python côté cible.
  changes = [
    "WORKDIR /app/azure-vote",
    "EXPOSE 80",
    "CMD [\"python3\", \"main.py\"]"
  ]
}

build {
  name    = "voting-app-docker-image"
  sources = ["source.docker.voting_app"]

  provisioner "shell" {
    inline = [
      "apt-get update",
      "DEBIAN_FRONTEND=noninteractive apt-get install -y python3"
    ]
  }

  provisioner "ansible" {
    playbook_file = "./playbook.yml"
    user          = "root"
  }

  post-processor "docker-tag" {
    repository = var.image_name
    tags       = [var.image_tag]
  }
}
