# Option 2 - Implement a simple web application in AWS

I'd like to see you provide the infrastructure-as-code to build out a web app to run in AWS. In order to match our need for automated infrastructure, it should be entirely buildable from a single command/script that can be run from the command line.
This web app should have an endpoint, http://hostname/builds, that accepts a POST request with the following sample payload...

```
{
    "jobs": {
        "Build base AMI": {
            "Builds": [{
                "runtime_seconds": "1931",
                "build_date": "1506741166",
                "result": "SUCCESS",
                "output": "base-ami us-west-2 ami-9f0ae4e5 d1541c88258ccb3ee565fa1d2322e04cdc5a1fda"
            }, {
                "runtime_seconds": "1825",
                "build_date": "1506740166",
                "result": "SUCCESS",
                "output": "base-ami us-west-2 ami-d3b92a92 3dd2e093fc75f0e903a4fd25240c89dd17c75d66"
            }, {
                "runtime_seconds": "126",
                "build_date": "1506240166",
                "result": "FAILURE",
                "output": "base-ami us-west-2 ami-38a2b9c1 936c7725e69855f3c259c117173782f8c1e42d9a"
            }, {
                "runtime_seconds": "1842",
                "build_date": "1506240566",
                "result": "SUCCESS",
                "output": "base-ami us-west-2 ami-91a42ed5 936c7725e69855f3c259c117173782f8c1e42d9a"
            }, {
                "runtime_seconds": "5",
                "build_date": "1506250561"
            }, {
                "runtime_seconds": "215",
                "build_date": "1506250826",
                "result": "FAILURE",
                "output": "base-ami us-west-2 ami-34a42e15 936c7725e69855f3c259c117173782f8c1e42d9a"
            }]
        }
    }
}
```

and should return a json formatted response like this...

```
{
    "latest": {
        "build_date": "xxxxxxx",
        "ami_id": "ami-xxxxxx",
        "commit_hash": "xxxxxxxxxxxx"
    }
}
```

where the build date, ami-id, and commit hash is the latest from the builds in the given payload. Assume that all build dates are epoch timestamps.

The infrastructure to support the web app should have:

1. Resources should be contained to a single region for this exercise.
2. 1 LB (any type you feel is suitable)
3. 1 compute instance
4. Any security groups needed to appropriately restrict access
5. A key pair to access the instance

The server serving the web app should be locked down so that only the load balancer can access it.

This should take about 3-4 hours.

The deliverable of this exercise is code demonstrating how this was deployed in the cloud. If you have a working example, feel free to demonstrate that as well.

# Implementation

## Summary

The chosen approach to this problem involves a combination of Hashicorp's Terraform and Packer applications with a bit of side help from Ansible for initial setup of the imaged instance. For the web app itself I've gone with Node.js to build an Express api server, managed on the deployed instance with PM2.

The deployment architecture consists of an autoscaling group limited to a single instance, with a launch configuration that is set to grab the latest uploaded ami in the host account that matches a predefined application tag. When terraform runs it will pick up on the existence of a new ami (created by packer) and will replace the launch configuration accordingly, and signal the autoscaling group to perform an instance refresh. This is done as a rolling restart, so existing nodes will note be removed from service until the new nodes are online and passing health checks.

The actual deployment can be kicked off with the use of a wrapper script (deploy.sh) which will initiate a new packer build to create an ami with the latest version of the application code, and proceed to automatically apply terraform to update the launch configuration.

## Prerequisites:

The single build / deploy script solution requires that the user has the following already configured on their system:

- Valid AWS credentials for their user
- Terraform and Packer installed locally

Instructions for how to do so will vary depending on the machine being used to perform the build / deploy, but should be easily found online.

The included terraform code also makes use of an s3 bucket for remote state storage, and a dynamodb table for state locking. The first time terraform runs these will not exist, and the init attempt will fail. Under ideal circumstances these resources would be previously existing through other shared infrastructure, but barring that the bootstrap solution is to simply comment out the "backend" code block in terraform/provider.tf for the first run, which will allow terraform to run and create the resources. After that the block can be uncommented and terraform init can be re-run to shift the local state to it's more appropriate remote location.

_Note:_ Additionally, the names listed here for the resources are specific to my own implementation, and will need to be changed if anyone else attempts to actually build and run this code. Specifically, S3 bucket names are required to be globally unique. Unfortunately terraform does not allow the use of variables within the backend configuration block, so the values are hard-coded to my own resources both in the provider.tf file, and in the remote_state.tf file that creates those resources, and will need to be changed in both locations.

## Security Concerns

Please note that the code as presented is _NOT_ geared for production usage and has several intentional security holes included in order to reduce the scope of the project and to keep the results clear and approachable.

In particular in a production environment there would almost certainly be additional layers of infrastructure surrounding an application deploy of this type, which would allow for additional security measures to be taken. In this type of environment we would want to add additional policies to the various resources, limiting which users are able to actually run the deploy and the locations from which it can run. The terraform state bucket certainly needs to be locked down properly, along with the dynamodb.

Additionally the security group for the compute node currently has ssh access open to the world, and would need to be placed in a public subnet to be accessed. Under normal circumstances the node would be deployed to a private subnet, and ssh access limited as much as possible, if not removed entirely.

That being said, depending on the organization it is very likely that some or all of the security configuration would exist outside of this repository regardless, as different teams would have different levels of security access, and the team developing the application code is rarely the team in charge of security.

I bring this up here mostly to point out that the lack of these things is not an oversight, merely a concession to the circumstances. Ultimately the approach used here answers the question as posed, but under real world circumstances it would probably be beneficial to take a deeper dive on the problem statement itself to try to come up with a solution that could solve the underlying problem while still allowing for proper separation of duties, code review, and any other workflows that would help a team of developers create and deploy their code as quickly and securely as possible. Implementation of a more generalized CI/CD infrastructure, as an example, would eliminate the need for a simple command line deploy and provide added stability and visibility to the deployment process. Switching to a container architecture removes the ability to directly access a compute instance, but for this type of application could provide better performance and faster deployment times. The provided solution works, and is viable for the semi-nebulous hypothetical of the exercise, but I don't believe it would be the correct approach for most concrete technical issues, and certainly not without considerable effort to expand and harden what is presented here.
