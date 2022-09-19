import json
import boto3
import os

master_instance_count = int(os.environ['MASTER_INSTANCE_COUNT'])
master_volume_size = int(os.environ['MASTER_VOLUME_SIZE'])
master_instance_type = os.environ['MASTER_INSTANCE_TYPE']
slave_instance_count = int(os.environ['SLAVE_INSTANCE_COUNT'])
slave_volume_size = int(os.environ['SLAVE_VOLUME_SIZE'])
slave_instance_type = os.environ['SLAVE_INSTANCE_TYPE']
ec2_subnet_id = os.environ['EC2_SUBNET_ID']
ec2key_name = os.environ['EC2KEY_NAME']
cluster_name = os.environ['CLUSTER_NAME']
#Release_Label = os.environ['RELEASE_LABEL']
emr_logs_path = os.environ['EMR_LOGS_PATH']
#bootstrap_path = os.environ['EMR_BOOTSTRAP_PATH']

client = boto3.client("emr")
def is_cluster_exists():
    cluster_Exists = False
    response = client.list_clusters(
        ClusterStates=[
            'STARTING', 'BOOTSTRAPPING', 'RUNNING', 'WAITING'
        ]
    )
    for cluster in response['Clusters']:
        if(cluster['Name'] == cluster_name):
            cluster_Exists = True
    return cluster_Exists


def lambda_handler(event, context):
    #create a cluster if one already not exists
    if not is_cluster_exists():
        print("Creating EMR")
        client = boto3.client('emr')
        print(event)
        cluster_id = client.run_job_flow(
            Name=cluster_name,
            LogUri=emr_logs_path,
            ReleaseLabel='emr-6.4.0',
            Applications=[
                {'Name': 'Spark'},
                {'Name': 'hadoop'},
            ],
            
            Instances={
                'InstanceGroups': [
                    {
                        'Name': 'Master nodes',
                        'Market': 'ON_DEMAND',
                        'InstanceRole': 'MASTER',
                        'InstanceType': master_instance_type,
                        'InstanceCount': master_instance_count,
                        'EbsConfiguration': {
                            'EbsBlockDeviceConfigs': [
                                {
                                        'VolumeSpecification': {
                                            'VolumeType': 'gp2',
                                            'SizeInGB': master_volume_size
                                        },
                                    'VolumesPerInstance': 1
                                },
                            ],

                            'EbsOptimized': True,
                        }
                    },
                    {
                        'Name': 'Slave nodes',
                        'Market': 'ON_DEMAND',
                        'InstanceRole': 'CORE',
                        'InstanceType': slave_instance_type,
                        'InstanceCount': slave_instance_count,
                        'EbsConfiguration': {
                            'EbsBlockDeviceConfigs': [
                                {
                                    'VolumeSpecification': {
                                        'VolumeType': 'gp2',
                                        'SizeInGB': slave_volume_size
                                    },
                                    'VolumesPerInstance': 1
                                },
                            ],
                            'EbsOptimized': True,
                            
                            
                        }
                        
                    }
                ],

                'KeepJobFlowAliveWhenNoSteps': False,
                'TerminationProtected': False,
                'Ec2KeyName': ec2key_name,
                'Ec2SubnetId': ec2_subnet_id,
            },
            
   #        BootstrapActions=[
    #            {
     #               'Name': 'InstallingSSM',
      #              'ScriptBootstrapAction': {
       #                 'Path': bootstrap_path,
        #            }
         #       },
          #  ],
        
            # EMR Steps
            Steps=[
                {
                    'Name': 'test-hello-world',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': 'command-runner.jar',
                        'Args': [
                            'spark-submit',
                            's3://dr-arch-tf-impetus-internal/sample.py'
                            ]
                    }
                }
            ],
            #AutoScalingRole='EMR_AutoScaling_DefaultRole',
            VisibleToAllUsers=True,
            JobFlowRole='EMR_EC2_DefaultRole',
            ServiceRole='EMR_DefaultRole',
            EbsRootVolumeSize=10
            
        )
        
        print ("Cluster:'" + cluster_name +"' is created with ClusterID:" + cluster_id['JobFlowId'])
    else:
        print ("Cluster:'" + cluster_name +"' is already exists")
