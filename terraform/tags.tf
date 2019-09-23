locals {
  common_tags = {
    environment = "${var.environment}"
    managed_by  = "${var.managed_by}"
  }
}
