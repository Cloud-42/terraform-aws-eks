## EKS

Upon launching the stack the following resources will be created:

 * 
 * 
 * 
 * 
 * 
 * 
 * 

## Dependencies and Prerequisites
 * Terraform v0.12. or higher
 * AWS account
 * VPC with private & public subnets
 * Host with Terraform , AWS CLI & kubectl installed

## Variables
| Variable | Meaning |
| :------- | :----- |
| `` |  |
| `` |  |
| `` |  |
| `` |  |
| `` |  |
| `` |  |
| `` |  |
| `` |  |
| `` |  |
| `` |  |
| `` |  |

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
  management_ip    = var.management_ip
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

#### Terraform commands
* To initialise the module run: terraform init
* To update the module run    : terraform get --update
* To see a plan of changes    : terraform plan
* To apply                    : terraform apply  
