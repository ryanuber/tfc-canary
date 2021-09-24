variable "name" { }

resource "random_id" "random" {
  keepers = {
    uuid = uuid()
  }
  byte_length = 8
}

output "id" {
  value = random_id.random.hex
}

output "name" {
  value = var.name
}
