resource "aws_vpc" "poc_vpc" {
  cidr_block = var.vpc-cidr
  enable_dns_hostnames = true
  tags = merge(
    {
      "Name" = format("%s", var.vpc-name)
    },
    var.tags,
  )
}

# Creating public subnets

resource "aws_subnet" "public_subnet" {
  count = length(var.public_subnets) > 0 ? length(var.public_subnets) : 0

  vpc_id = aws_vpc.poc_vpc.id
  cidr_block = element(var.public_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = merge(
    {
      "Name" = format(
        "%s-${var.public_subnet_name_suffix}-%s",
        var.vpc-name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
  )
}

# Creating private subnets

resource "aws_subnet" "private_subnet" {
  count = length(var.private_subnets) > 0 ? length(var.private_subnets) : 0

  vpc_id = aws_vpc.poc_vpc.id
  cidr_block = element(var.private_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = merge(
    {
      "Name" = format(
        "%s-${var.private_subnet_name_suffix}-%s",
        var.vpc-name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
  )
}

# Creating db subnets

resource "aws_subnet" "db_subnet" {
  count = length(var.db_subnets) > 0 ? length(var.db_subnets) : 0

  vpc_id = aws_vpc.poc_vpc.id
  cidr_block = element(var.db_subnets, count.index)
  availability_zone = element(var.availability_zones, count.index)
  tags = merge(
    {
      "Name" = format(
        "%s-${var.db_subnet_name_suffix}-%s",
        var.vpc-name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
  )
}

# Creatig Internet Gateway
resource "aws_internet_gateway" "poc_igw" {
  vpc_id = aws_vpc.poc_vpc.id

  tags = merge(
    {
      "Name" = format("%s", var.vpc-name)
    },
    var.tags,
  )
}

# Creatig Nat Gateway
resource "aws_nat_gateway" "poc_nat_gw" {
  count = length(var.availability_zones)

  allocation_id = element(
    aws_eip.nat_eip.*.id,
    count.index,
  )
  subnet_id = element(
    aws_subnet.public_subnet.*.id,
    count.index
  )

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.vpc-name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
  )

  depends_on = [aws_internet_gateway.poc_igw]
}

# Creatig EIP for NAT Gateway in All AZ
resource "aws_eip" "nat_eip" {
  count = length(var.availability_zones)

  vpc = true

  tags = merge(
    {
      "Name" = format(
        "%s-%s",
        var.vpc-name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
  )
}


# Publiс route table and routes for igw

resource "aws_route_table" "public_route_table" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  vpc_id = aws_vpc.poc_vpc.id
  tags = merge(
    {
      "Name" = format("%s-${var.public_subnet_name_suffix}", var.vpc-name)
    },
    var.tags,
  )
}

resource "aws_route" "public_igw_route" {
  count = length(var.public_subnets) > 0 ? 1 : 0

  route_table_id         = aws_route_table.public_route_table[0].id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.poc_igw.id

  timeouts {
    create = "5m"
  }
}
# Private route table and routes for each nat gw in each az

resource "aws_route_table" "private_route_table" {
  count = length(var.availability_zones)

  vpc_id = aws_vpc.poc_vpc.id

  tags = merge(
    {
      "Name" = format("%s-${var.private_subnet_name_suffix}-%s",
        var.vpc-name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
  )
}

resource "aws_route" "private_nat_route" {
  count = length(var.availability_zones)

  route_table_id         = element(aws_route_table.private_route_table.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.poc_nat_gw.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

# db subnet route tables

resource "aws_route_table" "db_routetable" {
  count = length(var.db_subnets)

  vpc_id = aws_vpc.poc_vpc.id

  tags = merge(
    {
      "Name" = format("%s-${var.db_subnet_name_suffix}-%s",
        var.vpc-name,
        element(var.availability_zones, count.index),
      )
    },
    var.tags,
  )
}

resource "aws_route" "db_natgw_route" {
  count = length(var.db_subnets)

  route_table_id         = element(aws_route_table.db_routetable.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.poc_nat_gw.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

# Route table association

resource "aws_route_table_association" "public_rtb_association" {
  count = length(var.public_subnets)

  subnet_id      = element(aws_subnet.public_subnet.*.id, count.index)
  route_table_id = aws_route_table.public_route_table[0].id
}

resource "aws_route_table_association" "private_rtb_association" {
  count = length(var.private_subnets)

  subnet_id = element(aws_subnet.private_subnet.*.id, count.index)
  route_table_id = element(
    aws_route_table.private_route_table.*.id,
    count.index,
  )
}

resource "aws_route_table_association" "db_rtb_association" {
  count = length(var.db_subnets)

  subnet_id = element(aws_subnet.db_subnet.*.id, count.index)
  route_table_id = element(aws_route_table.db_routetable.*.id, count.index)
}