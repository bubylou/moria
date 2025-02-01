group "default" {
  targets = ["build-dev"]
}

group "release-all" {
  targets = ["release-trim"]
}

variable "REPO" {
  default = "bubylou/moria"
}

variable "TAG" {
  default = "latest"
}

function "tags" {
  params = [suffix]
  result = ["ghcr.io/${REPO}:latest${suffix}", "ghcr.io/${REPO}:${TAG}${suffix}",
            "docker.io/${REPO}:latest${suffix}", "docker.io/${REPO}:${TAG}${suffix}"]
}

target "build" {
  context = "."
  dockerfile = "Dockerfile"
  cache-from = ["type=registry,ref=ghcr.io/${REPO}"]
  cache-to = ["type=inline"]
  tags = tags("")
}

target "build-dev" {
  inherits = ["build-trim"]
  env = {
    "STEAMCMD_VERSION" = "latest"
    "UPDATE_ON_START" = "false"
    "RESET_SEED" = "true"
  }
  tags = tags("-dev")
}

target "build-trim" {
  inherits = ["build"]
  args = {
    "RELEASE" = "trim"
  }
  tags = tags("-trim")
}

target "docker-metadata-action" {}
target "release" {
  inherits = ["build", "docker-metadata-action"]
  cache-from = ["type=gha"]
  cache-to = ["type=gha,mode=max"]
  attest = [
    "type=provenance,mode=max"
  ]
  platforms = ["linux/amd64"]
}

target "release-trim" {
  inherits = ["release", "build-trim"]
}
