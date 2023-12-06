resource "aws_vpc_peering_connection" "vpc-peering-same" {
  vpc_id      = aws_vpc.vpc-1.id
  peer_vpc_id = aws_vpc.vpc-2.id
  auto_accept = true
  accepter {
    allow_remote_vpc_dns_resolution = true
  }
  requester {
    allow_remote_vpc_dns_resolution = true
  }
  tags = {
    Name = "vpc-peering-same"
  }
}
