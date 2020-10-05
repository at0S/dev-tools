## S3 and Dynamo to enable remote storage for state file
When you manage infrastructure with Terraform, the most critical question to answer is how to manage the state file. State file keeps track on all assets you provision with Terraform and subsequent invocations of `terraform plan` and `apply` are working against this critcal artefact. 

In a very simple scenario, when aggressively prototyping, it is ok to keep the state file on the development machine. Experienced developers developed scar tissues and most probably making lots of offline backups of their working directories and if the state file is recoverable then they are almost in the good shape. 

The next level challenge comes into play when we start to work in a group. Now suddenly we need a mechanism to keep track of the current shape of state file and make sure if we have updates they propagate to our colleagues so that they can work against the most current state. 

Arguably, you already should consider the CI/CD process for your infrastructure and demand discipline for making changes. Ideally through version control and some centralised executor for Terraform. But what is going to happen if we have couple of changes booked, with a very short (like 30 sec) difference between the runs, but the change we applying is taking minutes to stabilise? Well, we can end up in trouble. 

Terraform developers put some good thinking in that early on. They provide a couple of ways to manage the state file, which they call `backends`, with prefered one being Consul backend. Consul is a great product, but not everyone would like to jump in and adopt it just for the sake of managing Terraform state files. For those, there is  an S3 backend also backed by the Dynamo table to provide a locking mechanism (remember that nasty situation with subsequent runs? Yes, to alleviate that).

To use S3 as a backend we will need:
1. An S3 bucket
2. Bucket policy to provide just enough access to the state file
3. Figure out the directory structure, so we can use the same bucket across several envrironments. That is a good exercise, but not a must. And also we can change that as we see need.
4. DynamoDB table with just one column, the lock id
5. Policy for this table

I think it is a bit ironic, as I'm managing above mentioned resources with CloudFormation. 