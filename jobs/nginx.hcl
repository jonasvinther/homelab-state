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

         volumes = [
          "custom/index.html:/etc/nginx/conf.d/default.conf"
        ]
      }

      template {
        data = <<EOH
        Nomad Template example (Consul value)
        <br />
        <br />
        {{ if keyExists "features/demo" }}
        Consul Key Value:  {{ key "features/demo" }}
        {{ else }}
          Good morning.
        {{ end }}
        <br />
        <br />
        Node Environment Information:  <br />
        node_id:     {{ env "node.unique.id" }} <br/>
        datacenter:  {{ env "NOMAD_DC" }}
        EOH
        destination = "custom/index.html"
      }
    }
  }
}