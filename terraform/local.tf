locals {
  name = "${var.app_name}-${var.environment}"

  common_tags = {
    environment = "${var.environment}"
    managed_by  = "${var.managed_by}"
  }
}
