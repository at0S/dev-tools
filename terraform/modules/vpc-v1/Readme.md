## AWS VPC module
Manages prototypical VPC with DMZ components. Exports resources to be consumed by the private subnets in the same VPC.

## Inputs
VPC CIDR.

### Resources
VPC, set of subnets, NAT and Internet gateways, components for flow logs.

### Outputs
VPC ID, DMZ network IDs, NAT Gateways IDs.