#            _    _ _    
#  _ __ _  _| |__| (_)__ 
# | '_ \ || | '_ \ | / _|
# | .__/\_,_|_.__/_|_\__|
# |_|                    
# 2 AZs - 1 subnet each
resource "aws_subnet" "public" {
  count                   = 2
  vpc_id                  = var.vpc_id
  cidr_block              = "10.0.${count.index}.0/24"
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "public-subnet-${count.index + 1}"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = var.vpc_id

  tags = {
    Name = "wl6-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public_route_table"
  }
}

resource "aws_route_table_association" "public" {
  count          = length(aws_subnet.public)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

#           _          _       
#  _ __ _ _(_)_ ____ _| |_ ___ 
# | '_ \ '_| \ V / _` |  _/ -_)
# | .__/_| |_|\_/\__,_|\__\___|
# |_|                          
# 2 AZs - 1 subnet each
resource "aws_subnet" "private" {
  count             = 2
  vpc_id            = var.vpc_id
  cidr_block        = "10.0.${count.index + 2}.0/24"
  availability_zone = var.availability_zones[count.index]
  tags = {
    Name = "private-subnet-${count.index + 1}"
  }
}

resource "aws_eip" "nat" {
  count  = 2
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  count         = 2
  allocation_id = aws_eip.nat[count.index].id
  subnet_id     = aws_subnet.public[count.index].id

  depends_on = [aws_internet_gateway.igw]
}

resource "aws_route_table" "private" {
  count  = 2
  vpc_id = var.vpc_id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.ngw[count.index].id
  }
}

resource "aws_route_table_association" "private" {
  count          = length(aws_subnet.private)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private[count.index].id
}

#                                   _           
# __ ___ __  __   _ __  ___ ___ _ _(_)_ _  __ _ 
# \ V / '_ \/ _| | '_ \/ -_) -_) '_| | ' \/ _` |
#  \_/| .__/\__| | .__/\___\___|_| |_|_||_\__, |
#     |_|        |_|                      |___/ 
# - default to wl6vpc
data "aws_vpc" "default" {
  default = true
}

data "aws_route_table" "default" {
  vpc_id = data.aws_vpc.default.id
}

resource "aws_vpc_peering_connection" "wl6peer" {
  peer_vpc_id = var.vpc_id
  vpc_id      = data.aws_vpc.default.id
  auto_accept = true
}

# add vpc peering route to default route table
resource "aws_route" "vpc_peering" {
  route_table_id            = data.aws_route_table.default.id
  destination_cidr_block    = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.wl6peer.id
}

resource "aws_route" "public_to_default" {
  route_table_id            = aws_route_table.public.id
  destination_cidr_block    = data.aws_vpc.default.cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.wl6peer.id
}
