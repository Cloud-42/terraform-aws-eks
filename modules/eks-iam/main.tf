# ---------------------------------------------------
# Cluster IAM Role
# ---------------------------------------------------
resource "aws_iam_role" "cluster" {
  name = "${var.eks_cluster_name}-cluster-role"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
# ---------------------------------------------------
# Attach AmazonEKSClusterPolicy
# ---------------------------------------------------
resource "aws_iam_role_policy_attachment" "cluster_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}
# ---------------------------------------------------
# Attach AmazonEKSServicePolicy
# ---------------------------------------------------
resource "aws_iam_role_policy_attachment" "service_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSServicePolicy"
  role       = aws_iam_role.cluster.name
}
# ---------------------------------------------------
# Nodes IAM Role
# ---------------------------------------------------
resource "aws_iam_role" "node" {
  name = "${var.eks_cluster_name}-node"

  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}
resource "aws_iam_role_policy_attachment" "attach_worker_node_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.node.name
}
resource "aws_iam_role_policy_attachment" "attach_eks_cni_policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.node.name
}
resource "aws_iam_role_policy_attachment" "attach_container_registry" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.node.name
}
resource "aws_iam_role_policy_attachment" "attach_ssm_readonly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
  role       = aws_iam_role.node.name
}
resource "aws_iam_instance_profile" "node_profile" {
  name = "${var.eks_cluster_name}-node"
  role = aws_iam_role.node.name
}
# ---------------------------------
# Attach Logging Policy to Node Role
# ---------------------------------
resource "aws_iam_role_policy_attachment" "attach_logging" {
  role       = aws_iam_role.node.name
  policy_arn = aws_iam_policy.logging.arn
}
# ------------------
# Logging Policy - Used for example by fluentd - CWLogs. https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/Container-Insights-setup-logs.html
# ------------------
resource "aws_iam_policy" "logging" {
  name        = "${var.eks_cluster_name}_node_logging_policy"
  path        = "/"
  description = "${var.eks_cluster_name} Logging IAM Policy"

  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "logs",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:CreateLogGroup",
                "logs:PutLogEvents",
                "logs:DescribeLogGroups",
                "logs:DescribeLogStreams",
                "cloudwatch:PutMetricData",
                "ec2:DescribeVolumes",
                "ec2:DescribeTags"
            ],
            "Resource": [
                "*"
            ]
        },
        {
            "Sid": "GetParameter",
            "Effect": "Allow",
            "Action": [
               "ssm:GetParameter"
             ],
             "Resource": [
                "arn:aws:ssm:*:*:parameter/AmazonCloudWatch-*"
             ]
         }  
    ]
}
EOF
}
# ---------------------------------
# Attach External DNS Policy to Node Role
# ---------------------------------
resource "aws_iam_role_policy_attachment" "attach_external_dns" {
  role       = aws_iam_role.node.name
  policy_arn = aws_iam_policy.external_dns.arn
}
# ------------------
# External DNS IAM Policy ( https://github.com/kubernetes-sigs/external-dns/blob/master/docs/tutorials/aws.md#iam-permissions )
# ------------------
resource "aws_iam_policy" "external_dns" {
  name        = "${var.eks_cluster_name}_node_external_dns_policy"
  path        = "/"
  description = "${var.eks_cluster_name} External DNS IAM Policy"

  policy = <<EOF
{
 "Version": "2012-10-17",
 "Statement": [
   {
     "Effect": "Allow",
     "Action": [
       "route53:ChangeResourceRecordSets"
     ],
     "Resource": [
       "arn:aws:route53:::hostedzone/*"
     ]
   },
   {
     "Effect": "Allow",
     "Action": [
       "route53:ListHostedZones",
       "route53:ListResourceRecordSets"
     ],
     "Resource": [
       "*"
     ]
   }
 ]
}
EOF
}
# ---------------------------------
# Attach AWS ALB ingress Policy to Node Role
# ---------------------------------
resource "aws_iam_role_policy_attachment" "attach_alb_ingress" {
  role       = aws_iam_role.node.name
  policy_arn = aws_iam_policy.alb_ingress.arn
}
# ------------------
# AWS ALB ingress IAM Policy ( https://aws.amazon.com/blogs/opensource/kubernetes-ingress-aws-alb-ingress-controller/ )
# ------------------
resource "aws_iam_policy" "alb_ingress" {
  name        = "${var.eks_cluster_name}_node_alb_ingress_policy"
  path        = "/"
  description = "${var.eks_cluster_name} ALB ingress IAM Policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "acm:Describe*",
        "acm:List*",
        "acm:Get*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "ec2:AuthorizeSecurityGroupIngress",
        "ec2:CreateSecurityGroup",
        "ec2:CreateTags",
        "ec2:DeleteTags",
        "ec2:DeleteSecurityGroup",
        "ec2:Describe*",
        "ec2:ModifyInstanceAttribute",
        "ec2:ModifyNetworkInterfaceAttribute",
        "ec2:RevokeSecurityGroupIngress"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "elasticloadbalancing:AddTags",
        "elasticloadbalancing:CreateListener",
        "elasticloadbalancing:CreateLoadBalancer",
        "elasticloadbalancing:CreateRule",
        "elasticloadbalancing:CreateTargetGroup",
        "elasticloadbalancing:DeleteListener",
        "elasticloadbalancing:DeleteLoadBalancer",
        "elasticloadbalancing:Describe*",
        "elasticloadbalancing:DeleteRule",
        "elasticloadbalancing:DeleteTargetGroup",
        "elasticloadbalancing:DeregisterTargets",
        "elasticloadbalancing:ModifyListener",
        "elasticloadbalancing:ModifyLoadBalancerAttributes",
        "elasticloadbalancing:ModifyRule",
        "elasticloadbalancing:ModifyTargetGroup",
        "elasticloadbalancing:ModifyTargetGroupAttributes",
        "elasticloadbalancing:RegisterTargets",
        "elasticloadbalancing:RemoveTags",
        "elasticloadbalancing:SetIpAddressType",
        "elasticloadbalancing:SetSecurityGroups",
        "elasticloadbalancing:SetSubnets",
        "elasticloadbalancing:SetWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:CreateServiceLinkedRole",
        "iam:Get*",
        "iam:List*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "iam:GetServerCertificate",
        "iam:ListServerCertificates"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf-regional:GetWebACLForResource",
        "waf-regional:GetWebACL",
        "waf-regional:AssociateWebACL",
        "waf-regional:DisassociateWebACL"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "tag:GetResources",
        "tag:TagResources"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "waf:GetWebACL"
      ],
      "Resource": "*"
    }
  ]
}
EOF
}
