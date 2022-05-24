job "traefik" {
  region      = "global"
  datacenters = ["dc1"]
  type        = "system"

  constraint {
    attribute = "${meta.type}"
    value     = "server"
  }

  group "traefik" {
    network {
      port "http" {
        static = 80
      }

      port "api" {
        static = 8081
      }
    }

    service {
      name = "traefik"

      check {
        name     = "alive"
        type     = "tcp"
        port     = "http"
        interval = "10s"
        timeout  = "2s"
      }
    }

    task "traefik" {
      driver = "docker"

      config {
        image        = "traefik:v2.6"
        network_mode = "host"

        volumes = [
          "local/traefik.toml:/etc/traefik/traefik.toml",
        ]
      }

      template {
        data = <<EOF
[entryPoints]
    [entryPoints.http]
    address = ":80"
    [entryPoints.traefik]
    address = ":8081"

[api]
    dashboard = true
    insecure  = true
[providers.consulCatalog]
  prefix           = "traefik"
  exposedByDefault = true
  connectAware = true
[providers.consulCatalog.endpoint]
  address = "http://192.168.1.102:8500"
  scheme  = "http"
EOF

        destination = "local/traefik.toml"
      }

      resources {
        cpu    = 100
        memory = 128
      }
    }
  }
}