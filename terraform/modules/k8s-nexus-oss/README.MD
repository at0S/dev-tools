## Deploys Nexus OSS with Kubernetes

### Notes
Mostly betting on `kubernetes` provider from `HashiCorp`, but still nees certain stuff to be provisioned with `kubernetes-alpha`. The difference between two is latter is allowing to create manifest rather than a particular type of manifest. `kubernetes-alpha` is very `alpha`, just to remind you. If something does not work - you out of luck.

### Assumptions
Will run withing EKS on AWS with the ALB as ingress controller. We potentially can consider 
other options to provide ingress in the future

### File system considerations
Could be deployed with ephemerial storage on the node but for real world usage we want to have access to persistent storage. Assuming we run in EKS on AWS, persistent volume is EFS. I might consider other storage options in the future.

### Blob storage considerations
Default blob store is using `nexus-data` directory and if it is EFS, its kind of OK. Still providing an option to store the blobs in S3. Once again, its all AWS specific at the moment.

### Inputs
TODO

### Outputs
TODO
