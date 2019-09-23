data "aws_availability_zones" "available" {}

resource "aws_vpc" "vpc" {
  cidr_block           = "${var.vpc_cidr}"
  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = "${merge(
          local.common_tags,
          map(
              "name", "${local.name}-vpc"
          )
      )}"
}

resource "aws_internet_gateway" "ig" {
  vpc_id = "${aws_vpc.vpc.id}"

  tags = "${merge(
          local.common_tags,
          map(
              "name", "${local.name}-ig"
          )
      )}"
}

resource "aws_eip" "nat" {
  count = "${var.az_count}"
  vpc   = true
}

resource "aws_nat_gateway" "gw" {
  count         = "${var.az_count}"
  subnet_id     = "${element(aws_subnet.public.*.id, count.index)}"
  allocation_id = "${element(aws_eip.nat.*.id, count.index)}"
}

resource "aws_subnet" "public" {
  count                   = "${var.az_count}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags = "${merge(
          local.common_tags,
          map(
              "name", "${local.name}-public-subnet-${count.index}"
          )
      )}"
}

resource "aws_subnet" "private" {
  count                   = "${var.az_count}"
  vpc_id                  = "${aws_vpc.vpc.id}"
  cidr_block              = "${cidrsubnet(aws_vpc.vpc.cidr_block, 8, count.index + 100)}"
  availability_zone       = "${data.aws_availability_zones.available.names[count.index]}"
  map_public_ip_on_launch = false

  tags = "${merge(
          local.common_tags,
          map(
              "name", "${local.name}-private-subnet-${count.index}"
          )
      )}"
}

resource "aws_route_table" "public" {
  count  = "${var.az_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = "${aws_internet_gateway.ig.id}"
  }

  tags = "${merge(
          local.common_tags,
          map(
              "name", "${local.name}-public-routes"
          )
      )}"
}

resource "aws_route_table" "private" {
  count  = "${var.az_count}"
  vpc_id = "${aws_vpc.vpc.id}"

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = "${element(aws_nat_gateway.gw.*.id, count.index)}"
  }

  tags = "${merge(
          local.common_tags,
          map(
              "name", "${local.name}-private-routes"
          )
      )}"
}

resource "aws_route_table_association" "public" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.public.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.public.*.id, count.index)}"
}

resource "aws_route_table_association" "private" {
  count          = "${var.az_count}"
  subnet_id      = "${element(aws_subnet.private.*.id, count.index)}"
  route_table_id = "${element(aws_route_table.private.*.id, count.index)}"
}
