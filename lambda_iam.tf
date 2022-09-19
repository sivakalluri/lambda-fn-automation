# AWS IAM ROLE
resource "aws_iam_role" "lambda_role" {
  name = "${local.name}-lambda-role"

  assume_role_policy = jsonencode({
    "Version" = "2012-10-17",
    "Statement" = [
      {
       "Action" = "sts:AssumeRole",
        "Effect" = "Allow",
        "Sid"    = "",
        "Principal" = {
          "Service" = "lambda.amazonaws.com"
        }
      }
    ]
  }
  )
}

#AWS IAM ROLE POLICY
resource "aws_iam_role_policy" "lambda_policy" {
  name = "${local.name}-lambda-policy"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
  "Version": "2012-10-17",
  "Statement": [
   {
    "Sid": "Stmt1649919261065",
    "Action": [
                  "logs:*",
                  "ec2:*"
              ],
    "Effect": "Allow",
    "Resource": "*"
    }
  ]
}
)
}

resource "aws_iam_role_policy" "iampasrole" {
    name = "${local.name}-IAMpassrole"
    role = aws_iam_role.lambda_role.id
  
    policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "*"
        }
    ]
}
)
}

resource "aws_iam_role_policy" "emrrunjobflow" {
  name = "${local.name}-emrRunJobFlow"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": "elasticmapreduce:RunJobFlow",
            "Resource": "*"
        }
    ]
}
)
}

resource "aws_iam_role_policy" "emrservicerole" {
    name = "${local.name}-emrServiceRole"
    role = aws_iam_role.lambda_role.id
  
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "CreateInTaggedNetwork",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterface",
                    "ec2:RunInstances",
                    "ec2:CreateFleet",
                    "ec2:CreateLaunchTemplate",
                    "ec2:CreateLaunchTemplateVersion"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:subnet/*",
                    "arn:aws:ec2:*:*:security-group/*"
                ],
                "Condition": {
                    "StringEquals": {
                        "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "CreateWithEMRTaggedLaunchTemplate",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateFleet",
                    "ec2:RunInstances",
                    "ec2:CreateLaunchTemplateVersion"
                ],
                "Resource": "arn:aws:ec2:*:*:launch-template/*",
                "Condition": {
                    "StringEquals": {
                        "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "CreateEMRTaggedLaunchTemplate",
                "Effect": "Allow",
                "Action": "ec2:CreateLaunchTemplate",
                "Resource": "arn:aws:ec2:*:*:launch-template/*",
                "Condition": {
                    "StringEquals": {
                        "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "CreateEMRTaggedInstancesAndVolumes",
                "Effect": "Allow",
                "Action": [
                    "ec2:RunInstances",
                    "ec2:CreateFleet"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:instance/*",
                    "arn:aws:ec2:*:*:volume/*"
                ],
                "Condition": {
                    "StringEquals": {
                        "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "ResourcesToLaunchEC2",
                "Effect": "Allow",
                "Action": [
                    "ec2:RunInstances",
                    "ec2:CreateFleet",
                    "ec2:CreateLaunchTemplate",
                    "ec2:CreateLaunchTemplateVersion"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:network-interface/*",
                    "arn:aws:ec2:*::image/ami-*",
                    "arn:aws:ec2:*:*:key-pair/*",
                    "arn:aws:ec2:*:*:capacity-reservation/*",
                    "arn:aws:ec2:*:*:placement-group/EMR_*",
                    "arn:aws:ec2:*:*:fleet/*",
                    "arn:aws:ec2:*:*:dedicated-host/*",
                    "arn:aws:resource-groups:*:*:group/*"
                ]
            },
            {
                "Sid": "ManageEMRTaggedResources",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateLaunchTemplateVersion",
                    "ec2:DeleteLaunchTemplate",
                    "ec2:DeleteNetworkInterface",
                    "ec2:ModifyInstanceAttribute",
                    "ec2:TerminateInstances"
                ],
                "Resource": "*",
                "Condition": {
                    "StringEquals": {
                        "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "ManageTagsOnEMRTaggedResources",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateTags",
                    "ec2:DeleteTags"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:instance/*",
                    "arn:aws:ec2:*:*:volume/*",
                    "arn:aws:ec2:*:*:network-interface/*",
                    "arn:aws:ec2:*:*:launch-template/*"
                ],
                "Condition": {
                    "StringEquals": {
                        "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "CreateNetworkInterfaceNeededForPrivateSubnet",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateNetworkInterface"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:network-interface/*"
                ],
                "Condition": {
                    "StringEquals": {
                        "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "TagOnCreateTaggedEMRResources",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateTags"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:network-interface/*",
                    "arn:aws:ec2:*:*:instance/*",
                    "arn:aws:ec2:*:*:volume/*",
                    "arn:aws:ec2:*:*:launch-template/*"
                ],
                "Condition": {
                    "StringEquals": {
                        "ec2:CreateAction": [
                            "RunInstances",
                            "CreateFleet",
                            "CreateLaunchTemplate",
                            "CreateNetworkInterface"
                        ]
                    }
                }
            },
            {
                "Sid": "TagPlacementGroups",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateTags",
                    "ec2:DeleteTags"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:placement-group/EMR_*"
                ]
            },
            {
                "Sid": "ListActionsForEC2Resources",
                "Effect": "Allow",
                "Action": [
                    "ec2:DescribeAccountAttributes",
                    "ec2:DescribeCapacityReservations",
                    "ec2:DescribeDhcpOptions",
                    "ec2:DescribeImages",
                    "ec2:DescribeInstances",
                    "ec2:DescribeLaunchTemplates",
                    "ec2:DescribeNetworkAcls",
                    "ec2:DescribeNetworkInterfaces",
                    "ec2:DescribePlacementGroups",
                    "ec2:DescribeRouteTables",
                    "ec2:DescribeSecurityGroups",
                    "ec2:DescribeSubnets",
                    "ec2:DescribeVolumes",
                    "ec2:DescribeVolumeStatus",
                    "ec2:DescribeVpcAttribute",
                    "ec2:DescribeVpcEndpoints",
                    "ec2:DescribeVpcs"
                ],
                "Resource": "*"
            },
            {
                "Sid": "CreateDefaultSecurityGroupWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateSecurityGroup"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:security-group/*"
                ],
                "Condition": {
                    "StringEquals": {
                        "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "CreateDefaultSecurityGroupInVPCWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateSecurityGroup"
                ],
                "Resource": [
                    "arn:aws:ec2:*:*:vpc/*"
                ],
                "Condition": {
                    "StringEquals": {
                        "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "TagOnCreateDefaultSecurityGroupWithEMRTags",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreateTags"
                ],
                "Resource": "arn:aws:ec2:*:*:security-group/*",
                "Condition": {
                    "StringEquals": {
                        "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true",
                        "ec2:CreateAction": "CreateSecurityGroup"
                    }
                }
            },
            {
                "Sid": "ManageSecurityGroups",
                "Effect": "Allow",
                "Action": [
                    "ec2:AuthorizeSecurityGroupEgress",
                    "ec2:AuthorizeSecurityGroupIngress",
                    "ec2:RevokeSecurityGroupEgress",
                    "ec2:RevokeSecurityGroupIngress"
                ],
                "Resource": "*",
                "Condition": {
                    "StringEquals": {
                        "aws:ResourceTag/for-use-with-amazon-emr-managed-policies": "true"
                    }
                }
            },
            {
                "Sid": "CreateEMRPlacementGroups",
                "Effect": "Allow",
                "Action": [
                    "ec2:CreatePlacementGroup"
                ],
                "Resource": "arn:aws:ec2:*:*:placement-group/EMR_*"
            },
            {
                "Sid": "DeletePlacementGroups",
                "Effect": "Allow",
                "Action": [
                    "ec2:DeletePlacementGroup"
                ],
                "Resource": "*"
            },
            {
                "Sid": "AutoScaling",
                "Effect": "Allow",
                "Action": [
                    "application-autoscaling:DeleteScalingPolicy",
                    "application-autoscaling:DeregisterScalableTarget",
                    "application-autoscaling:DescribeScalableTargets",
                    "application-autoscaling:DescribeScalingPolicies",
                    "application-autoscaling:PutScalingPolicy",
                    "application-autoscaling:RegisterScalableTarget"
                ],
                "Resource": "*"
            },
            {
                "Sid": "ResourceGroupsForCapacityReservations",
                "Effect": "Allow",
                "Action": [
                    "resource-groups:ListGroupResources"
                ],
                "Resource": "*"
            },
            {
                "Sid": "AutoScalingCloudWatch",
                "Effect": "Allow",
                "Action": [
                    "cloudwatch:PutMetricAlarm",
                    "cloudwatch:DeleteAlarms",
                    "cloudwatch:DescribeAlarms"
                ],
                "Resource": "arn:aws:cloudwatch:*:*:alarm:*_EMR_Auto_Scaling"
            },
            {
                "Sid": "PassRoleForAutoScaling",
                "Effect": "Allow",
                "Action": "iam:PassRole",
                "Resource": "arn:aws:iam::*:role/EMR_AutoScaling_DefaultRole",
                "Condition": {
                    "StringLike": {
                        "iam:PassedToService": "application-autoscaling.amazonaws.com*"
                    }
                }
            },
            {
                "Sid": "PassRoleForEC2",
                "Effect": "Allow",
                "Action": "iam:PassRole",
                "Resource": "arn:aws:iam::*:role/EMR_EC2_DefaultRole",
                "Condition": {
                    "StringLike": {
                        "iam:PassedToService": "ec2.amazonaws.com*"
                    }
                }
            }
        ]
    }
  )
  }

resource "aws_iam_role_policy" "emrrunreadonly" {
    name = "${local.name}-emrRunReadOnly"
    role = aws_iam_role.lambda_role.id
  
    policy = jsonencode({
        "Version": "2012-10-17",
        "Statement": [
            {
                "Sid": "ElasticMapReduceActions",
                "Effect": "Allow",
                "Action": [
                    "elasticmapreduce:DescribeCluster",
                    "elasticmapreduce:DescribeEditor",
                    "elasticmapreduce:DescribeJobFlows",
                    "elasticmapreduce:DescribeSecurityConfiguration",
                    "elasticmapreduce:DescribeStep",
                    "elasticmapreduce:DescribeReleaseLabel",
                    "elasticmapreduce:GetBlockPublicAccessConfiguration",
                    "elasticmapreduce:GetManagedScalingPolicy",
                    "elasticmapreduce:GetAutoTerminationPolicy",
                    "elasticmapreduce:ListBootstrapActions",
                    "elasticmapreduce:ListClusters",
                    "elasticmapreduce:ListEditors",
                    "elasticmapreduce:ListInstanceFleets",
                    "elasticmapreduce:ListInstanceGroups",
                    "elasticmapreduce:ListInstances",
                    "elasticmapreduce:ListSecurityConfigurations",
                    "elasticmapreduce:ListSteps",
                    "elasticmapreduce:ViewEventsFromAllClustersInConsole"
                ],
                "Resource": "*"
            },
            {
                "Sid": "ViewMetricsInEMRConsole",
                "Effect": "Allow",
                "Action": [
                    "cloudwatch:GetMetricStatistics"
                ],
                "Resource": "*"
            }
        ]
    }
  )
  }


resource "aws_iam_role_policy" "emrrunjobfull" {
  name = "${local.name}-emrRunJobFull"
  role = aws_iam_role.lambda_role.id

  policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "RunJobFlowExplicitlyWithEMRManagedTag",
            "Effect": "Allow",
            "Action": [
                "elasticmapreduce:RunJobFlow"
            ],
            "Resource": "*",
            "Condition": {
                "StringEquals": {
                    "aws:RequestTag/for-use-with-amazon-emr-managed-policies": "true"
                }
            }
        },
        {
            "Sid": "ElasticMapReduceActions",
            "Effect": "Allow",
            "Action": [
                "elasticmapreduce:AddInstanceFleet",
                "elasticmapreduce:AddInstanceGroups",
                "elasticmapreduce:AddJobFlowSteps",
                "elasticmapreduce:AddTags",
                "elasticmapreduce:CancelSteps",
                "elasticmapreduce:CreateEditor",
                "elasticmapreduce:CreateSecurityConfiguration",
                "elasticmapreduce:DeleteEditor",
                "elasticmapreduce:DeleteSecurityConfiguration",
                "elasticmapreduce:DescribeCluster",
                "elasticmapreduce:DescribeEditor",
                "elasticmapreduce:DescribeJobFlows",
                "elasticmapreduce:DescribeSecurityConfiguration",
                "elasticmapreduce:DescribeStep",
                "elasticmapreduce:DescribeReleaseLabel",
                "elasticmapreduce:GetBlockPublicAccessConfiguration",
                "elasticmapreduce:GetManagedScalingPolicy",
                "elasticmapreduce:GetAutoTerminationPolicy",
                "elasticmapreduce:ListBootstrapActions",
                "elasticmapreduce:ListClusters",
                "elasticmapreduce:ListEditors",
                "elasticmapreduce:ListInstanceFleets",
                "elasticmapreduce:ListInstanceGroups",
                "elasticmapreduce:ListInstances",
                "elasticmapreduce:ListSecurityConfigurations",
                "elasticmapreduce:ListSteps",
                "elasticmapreduce:ModifyCluster",
                "elasticmapreduce:ModifyInstanceFleet",
                "elasticmapreduce:ModifyInstanceGroups",
                "elasticmapreduce:OpenEditorInConsole",
                "elasticmapreduce:PutAutoScalingPolicy",
                "elasticmapreduce:PutBlockPublicAccessConfiguration",
                "elasticmapreduce:PutManagedScalingPolicy",
                "elasticmapreduce:RemoveAutoScalingPolicy",
                "elasticmapreduce:RemoveManagedScalingPolicy",
                "elasticmapreduce:RemoveTags",
                "elasticmapreduce:SetTerminationProtection",
                "elasticmapreduce:StartEditor",
                "elasticmapreduce:StopEditor",
                "elasticmapreduce:TerminateJobFlows",
                "elasticmapreduce:ViewEventsFromAllClustersInConsole"
            ],
            "Resource": "*"
        },
        {
            "Sid": "ViewMetricsInEMRConsole",
            "Effect": "Allow",
            "Action": [
                "cloudwatch:GetMetricStatistics"
            ],
            "Resource": "*"
        },
        {
            "Sid": "PassRoleForElasticMapReduce",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/EMR_DefaultRole_V2",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "elasticmapreduce.amazonaws.com*"
                }
            }
        },
        {
            "Sid": "PassRoleForEC2",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/EMR_EC2_DefaultRole",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "ec2.amazonaws.com*"
                }
            }
        },
        {
            "Sid": "PassRoleForAutoScaling",
            "Effect": "Allow",
            "Action": "iam:PassRole",
            "Resource": "arn:aws:iam::*:role/EMR_AutoScaling_DefaultRole",
            "Condition": {
                "StringLike": {
                    "iam:PassedToService": "application-autoscaling.amazonaws.com*"
                }
            }
        },
        {
            "Sid": "ElasticMapReduceServiceLinkedRole",
            "Effect": "Allow",
            "Action": "iam:CreateServiceLinkedRole",
            "Resource": "arn:aws:iam::*:role/aws-service-role/elasticmapreduce.amazonaws.com*/AWSServiceRoleForEMRCleanup*",
            "Condition": {
                "StringEquals": {
                    "iam:AWSServiceName": [
                        "elasticmapreduce.amazonaws.com",
                        "elasticmapreduce.amazonaws.com.cn"
                    ]
                }
            }
        },
        {
            "Sid": "ConsoleUIActions",
            "Effect": "Allow",
            "Action": [
                "ec2:DescribeAccountAttributes",
                "ec2:DescribeAvailabilityZones",
                "ec2:DescribeImages",
                "ec2:DescribeKeyPairs",
                "ec2:DescribeNatGateways",
                "ec2:DescribeRouteTables",
                "ec2:DescribeSecurityGroups",
                "ec2:DescribeSubnets",
                "ec2:DescribeVpcs",
                "ec2:DescribeVpcEndpoints",
                "s3:ListAllMyBuckets",
                "iam:ListRoles"
            ],
            "Resource": "*"
        }
    ]
}
  )
}

