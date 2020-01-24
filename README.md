<p align="center">
  <a href="https://www.cloud42.io/" target="_blank" rel="Homepage">
  <img width="200" height="200" src="https://www.cloud42.io/wp-content/uploads/2020/01/transparent_small.png">
  </a>
</p>

---
<p align="center">Need help with your Cloud builds <a href="https://www.cloud42.io/contact/" target="_blank" rel="ContactUS"> GET IN TOUCH</a>.</p>

---
## EKS

Upon launching the stack the following resources will be created:

 * EKS cluster.
 * ec2 Launch Template.
 * ASG worker nodes.
 * IAM roles - Control Plane and worker nodes.
 * Security Groups - Control Plane and worker nodes.
 * CloudWatch log group.

**Note:**
The intial release has been tested and works however this module should be considered "under-development" as further updates and improvments are expected.

## Dependencies and Prerequisites
 * Terraform v0.12. or higher
 * AWS account
 * VPC with private & public subnets
 * Host with Terraform , AWS CLI & kubectl installed

## Variables
| Variable | Meaning |
| :------- | :----- |
| management_cidr| CIDR range which is granted access to the control plane. Usually the VPC CIDR range or similar. Not to be confused with public_access_cidrs.  |
| endpoint_private_access | Enable private API server endpoint access |
| endpoint_public_access | Enable public API server endpoint access |
| subnet_ids | Subnets ids where the control plane should be deployed |
| kubernetes_version | K8s version |
| eks_cluster_name | Cluster Name  |
| vpc_id | VPC id  |
| log_retention_in_days  | CloudWatch log group retention in days  |
| enabled_cluster_log_types | Cluster log types to enable |
| region | AWS region |
| eks_worker_ssh_key_name | EKS workers - default ssh key to launch hosts with  |
| eks_worker_subnet_ids | EKS workers - Subnets in which to launch worker nodes  |
| eks_worker_group_name | EKS workers - group name |
| eks_worker_ami | EKS workers - AMI to use for launching worker nodes |
| eks_worker_on_demand_base_capacity | EKS workers - minimum amount of desired capacity that must be fulfilled by on-demand instances.  |
| eks_worker_on_demand_percentage_above_base_capacity | EKS workers - Percentage split between on-demand and Spot instances above the base on-demand capacity  |
| eks_worker_instance_type | EKS workers - instance type |
| public_access_cidrs | List of CIDR blocks that can access the public endpoint when it is enabled |

## Outputs
 * endpoint
 * kubeconfig-certificate-authority-data
  
## Usage

To import the module add the following to the your TF file:
```
module "eks" {
  
  source = "git::https://github.com/Cloud-42/terraform-aws-eks.git"
  
  # -------------
  # Control Plane
  # -------------
  subnet_ids       = ["${element(split(",", module.vpc.subnets_public), 0)}","${element(split(",", module.vpc.subnets_public), 1)}","${element(split(",", module.vpc.subnets_private), 0)}","${element(split(",", module.vpc.subnets_private), 1)}"]
  eks_cluster_name = var.eks_name
  vpc_id           = module.vpc.vpc_id
  management_cidr  = var.management_cidr
  region           = var.aws_region
  # -------------
  # Workers
  # -------------
  eks_worker_instance_type = [
  {
    "instance_type" = "t3a.medium"
  },
  {
    "instance_type" = "t3.medium"
  },
  {
    "instance_type" = "t2.medium"
  }
  ]

  eks_worker_ssh_key_name                             = var.key_name
  eks_worker_subnet_ids                               = ["${element(split(",", module.vpc.subnets_private), 0)}", "${element(split(",", module.vpc.subnets_private), 1)}"]
  eks_worker_on_demand_base_capacity                  = "0"
  eks_worker_on_demand_percentage_above_base_capacity = "0"
  eks_worker_ami                                      = data.aws_ami.latest_worker_ami.id
  eks_worker_group_name                               = var.eks_name
}
# -----------------------
# Echo out configs
# -----------------------
output "kubeconfig" { value = module.eks.kubeconfig }

output "config-map-aws-auth" { value = module.eks.config-map-aws-auth }
```

### Setup kubectl
```
terraform output kubeconfig > ~/.kube/eks-cluster
export KUBECONFIG=~/.kube/eks-cluster
```

### Authorize worker nodes
```
terraform output config-map-aws-auth > config-map-aws-auth.yaml
kubectl apply -f config-map-aws-auth.yaml
```

### Terraform commands
* To initialise the module run: terraform init
* To update the module run    : terraform get --update
* To see a plan of changes    : terraform plan
* To apply                    : terraform apply  

### Useful links
<a href="https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html" target="_blank">https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html</a>
<a href="https://kubernetes.io/docs/tasks/tools/install-kubectl/" target="_blank">https://kubernetes.io/docs/tasks/tools/install-kubectl/</a>

