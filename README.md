# dev-tools
Common tools, to support development, in a single repo, backed by Terraform

## Goal
Mostly to get in shape with Terraform, but also practice some tool maintenance ideas. I plan to keep it as a mono repository to see how actually hard (or not) it is to keep components organised that way. 

## Repository structure
I plan to have services in a single AWS account, most probably in the single VPC. So, loosely:
```
|
\Common
  |
  infra\
  Readme.md
\ServiceA
  |
  Readme.md
  infra\
  app\
\ServiceB
  |
  Readme.md
  infra\
  app
```
But that is work in progress, just starting out.

## Commit signatures
I finally started to use my new Yubikey 5, so its time to sign commits

## CI/CD
Yes, with GitHub Actions I think, how it will work - TBA. Will it use TerraformCloud? Meh, but - will see. For the context, we can keep our state file there (which is handy), it also provides `terraform` runners. Don't really want to exercise that for now.
