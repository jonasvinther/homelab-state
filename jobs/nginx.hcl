job "nginx" {
  
  datacenters = [
    "dc1"
    ]
  type = "service"

  group "app" {
    count = 1

    network {
      port "http" {
        to = 80
      }
    }

    service {
      name = "nginx"
      port = "http"

      tags = [
        "traefik.enable=true",
        "traefik.http.routers.webapp.rule=Host(`pi.crunk.dk`)"
      ]

      check {
        name     = "alive"
        type     = "http"
        path     = "/"
        interval = "10s"
        timeout  = "2s"
      }

    }

    restart {
      attempts = 2
      interval = "30m"
      delay = "15s"
      mode = "fail"
    }

    task "server" {
      driver = "docker"

      config {
        image = "nginx"
        ports = ["http"]
      }
    }
  }
}