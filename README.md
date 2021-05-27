# EKS and Terraform

This repository shows examples and guides for using [Terraform](https://terraform.io) to provision a [EKS (Elastic Kubernetes Service) Cluster](https://aws.amazon.com/eks/) on AWS

## Instructions

### Step 1 - Fork and clone

Fork this repository into your own GitHub account and then clone (your forked version) down to your local machine.

### Step 2 - Install and configure the AWS CLI

We'll use the AWS CLI to get information from the cluster. Follow this step if you haven't yet installed the AWS CLI.

To install this you can install manually by following [these instructions](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) or if you have a package manager you can use the instructions below:

**Mac Homebrew**

```
brew install awscli
```

**Windows Chocolatey**

```
choco install awscli
```

### Step 3 - Install kubectl tool

The `kubectl` tool will be utilised to interact with your Kubernetes (K8S) cluster.

You can install this manually by following this guide below:

https://kubernetes.io/docs/tasks/tools/install-kubectl/

Or alternatively if you use a package manager it can be installed using the package manager:

**Homebrew**

```
brew install kubernetes-cli
```

**Chocolatey**

```
choco install kubernetes-cli
```

You can verify that it has installed correctly by running 

```
kubectl version
```

It should print something like the below:

```
Client Version: version.Info{Major:"1", Minor:"20", GitVersion:"v1.20.4", GitCommit:"e87da0bd6e03ec3fea7933c4b5263d151aafd07c", GitTreeState:"clean", BuildDate:"2021-02-21T20:21:49Z", GoVersion:"go1.15.8", Compiler:"gc", Platform:"darwin/amd64"}
```

Dont worry if it says "Unable to connect to server" at this stage. We'll be sorting that later.

### Step 4 - Explore the files

Before we go ahead and create your cluster its worth exploring the files.

Oh and before we do explore, the files in this directory could have been named whatever we like. For example the **outputs.tf** file can have been called **foo.tf** - we just chose to call it that because it contained outputs. So the naming was more of a standard than a requirement.

**vpc.tf**

Provisions and creates the Virtual Private Cloud (remember those from session two) that your cluster will be placed in.

**security-groups.tf**

Creates the [AWS security groups](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-security-groups.html) for the cluster.

**eks-cluster.tf** 

Provisions all the resources (AutoScaling Groups, etc...) required to set up an EKS cluster using the [AWS EKS Module](https://registry.terraform.io/modules/terraform-aws-modules/eks/aws/11.0.0).

**outputs.tf**

This file defines the outputs that will be produced by terraform when things have been provisioned.

**versions.tf** 

Configures the terraform providers (in our case the AWS provider) and sets the Terraform version to at least 0.14.

**terraform.tfvars**

This contains the values for the variables utilised in the terraform files. Make sure that the region looks correct and the **credentials-profile** should be as per the entry in your `~/.aws/credentials` that you set up after following the videos prior to session 3.

### Step 5 - Update the tfvars file

Optionally update the tfvars file and ensure that the **credentials-profile** should be as per the entry in your `~/.aws/credentials` that you set up after following the videos prior to session 3.

### Step 6 - Initialise terraform

We need to get terraform to pull down the AWS provider.

In order to do this run:

```
terraform init
```

You should see something similar to the below:

```
Initializing modules...

Initializing the backend...

Initializing provider plugins...
- Reusing previous version of hashicorp/random from the dependency lock file
- Reusing previous version of hashicorp/local from the dependency lock file
- Reusing previous version of hashicorp/null from the dependency lock file
- Reusing previous version of hashicorp/template from the dependency lock file
- Reusing previous version of hashicorp/kubernetes from the dependency lock file
- Reusing previous version of hashicorp/aws from the dependency lock file
```

### Step 7 - Review changes with a plan

Firstly run a **plan** to see if what Terraform decides will happen.

```
terraform plan
```

### Step 8 - Create your cluster with apply

We can then create your cluster by applying the configuration.

```
terraform apply
```

Sit back and relax - it might take 10 mins or so to create your cluster. Perfect time to have a ☕️  or a chat together.

Once its finished it'll output something like the info below. Those **outputs** are defined in the **outputs.tf** file.

```
Apply complete! Resources: 53 added, 0 changed, 0 destroyed.

Outputs:

cluster_endpoint = "https://C5CC135B19D791072B60A325678379BE.gr7.eu-west-2.eks.amazonaws.com"
cluster_id = "devops-upskill-eks"
cluster_name = "devops-upskill-eks"
cluster_security_group_id = "sg-099d37e0a02ad6eae"
```

Once its done you'll have a your Kubernetes cluster all ready to go!!!

### Step 9 - Configure your **kube control** 

**kubectl** is used to issue actions on our cluster.

We need to configure **kubectl** to be able to authenticate with your cluster.

To do this we use the AWS CLI to get the credentials. Notice how we reference the outputs in the command below. 

**NOTE** Replace the `terraform-iac` part with whatever your AWS Credentials profile is called in `~/.aws/credentials`

```
aws eks --region $(terraform output -raw region) update-kubeconfig --name $(terraform output -raw cluster_name) --profile terraform-iac
```

It should say something like:

```
Added new context arn:aws:eks:eu-west-2:1234567:cluster/devops-upskill-eks to /Users/user/.kube/config
```

### Step 10 - Check if kubectl can access cluster

You can now verify if `kubectl` can access your cluster.

Go ahead and see how many nodes are running:

```
kubectl get nodes
```

It should show something like:

```
NAME                                       STATUS   ROLES    AGE   VERSION
ip-10-0-1-216.eu-west-2.compute.internal   Ready    <none>   70s   v1.19.6-eks-49a6c0
ip-10-0-2-161.eu-west-2.compute.internal   Ready    <none>   71s   v1.19.6-eks-49a6c0
ip-10-0-2-186.eu-west-2.compute.internal   Ready    <none>   75s   v1.19.6-eks-49a6c0
```

Exciting eh!!!

### Step 11 - Deploying your first app in a pod!!

Finally lets get a container running on your cluster.

Firstly check if there are any running pods

```
kubectl get pods
```

It should probably say something like this:

```
No resources found in default namespace.
```

Lets deploy the nginx deployment.

```
kubectl apply -f kubernetes/nginx-deployment.yaml
```

Now lets see the pods

```
kubectl get pods
```

And it will show something like this:

```
NAME                                READY   STATUS    RESTARTS   AGE
nginx-deployment-5cd5cdbcc4-b46m7   1/1     Running   0          14s
nginx-deployment-5cd5cdbcc4-knxss   1/1     Running   0          14s
nginx-deployment-5cd5cdbcc4-sqm2p   1/1     Running   0          14s
```

Actually you know what, I think 3 replicas is a bit overkill. Lets bring it down to 2 replicas.

Update the nginx-deployment.yaml file and change it down to 2 and save the file.

Then re-run your deployment.

```
kubectl apply -f kubernetes/nginx-deployment.yaml
```

Now lets see the pods

```
kubectl get pods
```

And you should see something like this:

```
NAME                                READY   STATUS        RESTARTS   AGE
nginx-deployment-5cd5cdbcc4-b46m7   1/1     Running       0          3m47s
nginx-deployment-5cd5cdbcc4-knxss   1/1     Running       0          3m47s
nginx-deployment-5cd5cdbcc4-sqm2p   0/1     Terminating   0          3m47s
```

### Step 12 - Exposing your webserver

Finally lets get that web server exposed to the internet with a **service**

We can do this by creating the service (which will sit in front of our pods) and the ingress point

Firstly create the service

```
kubectl apply -f kubernetes/nginx-service.yaml
```

Kubernetes will now create the required load balancer and create an external IP address.

Keep running the command below until you see an external IP address

```
 kubectl get services
```

It should output something like this:

```
NAME               TYPE           CLUSTER-IP   EXTERNAL-IP      PORT(S)        AGE
kubernetes         ClusterIP      10.0.0.1     <none>           443/TCP        4m54s
nginx-web-server   LoadBalancer   10.0.94.47   a68661a55a68b47119adce3090730169-897732735.eu-west-2.elb.amazonaws.com   80:32580/TCP   7s
```

### Step 13 - Marvel at your creation

After around 5 to 10 mins you should be able to hit the endpoint with your browser. Using the example above I would go to: http://a68661a55a68b47119adce3090730169-897732735.eu-west-2.elb.amazonaws.com

**NOTE** It does take a few mins, for some time you might see a 404 page.

### Step 14 - Tearing down your cluster

Finally we want to destroy our cluster.

Firstly lets remove the service and ingress

```
kubectl delete -f kubernetes/nginx-service.yaml
```

Then we can destroy the cluster in full.

```
terraform destroy
```
