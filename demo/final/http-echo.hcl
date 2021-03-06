job "http-echo" {
  datacenters = ["dc1"]
  type = "service"
  
  update {
    max_parallel = 1
  }

  group "http-echo" {
    count = 2
    
    task "http-echo" {
      
      driver = "exec"
      
      config {
        command = "http-echo"
        args = [
          "-text",
          "<h1>Instance: ${NOMAD_ALLOC_INDEX} IP: ${NOMAD_ADDR_http} PASSWORD: ${PASSWORD} Version: ${VERSION}</h1>",
          "-listen",
          "${NOMAD_ADDR_http}"
        ]
      }

      env {
        "VERSION" = "1"
      }

      resources {
        memory = 100

        network {
          port "http" {}
        }
      }

      service {
        port = "http"
        name = "http-echo"

        check {
          type = "http"
          path = "/health"
          interval = "10s"
          timeout = "2s"
        }
      }

      vault {
        policies = ["http-echo"]
      }

      template {
          data = <<EOH
PASSWORD="{{with secret "secret/data/http-echo"}}{{.Data.data.PASSWORD}}{{end}}"
EOH
          destination = "secrets/file.env"
          env         = true
      }
    }
  }
}
