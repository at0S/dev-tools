output "vpc_id" {
    value = aws_vpc.this.id
}

output "dmz_subnet_ids" {
    value = tolist(aws_subnet.dmz.*.id)
}

output "sunbets" {
    value = aws_subnet.dmz.*.availability_zone 
}