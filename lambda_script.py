import json
import boto3
import datetime
import os
import math
master_instance_count = int(os.environ['MASTER_INSTANCE_COUNT'])
master_volume_size = int(os.environ['MASTER_VOLUME_SIZE'])
master_instance_type = os.environ['MASTER_INSTANCE_TYPE']
slave_instance_count = int(os.environ['SLAVE_INSTANCE_COUNT'])
   
slave_core_instance_count=slave_instance_count

slave_volume_size = int(os.environ['SLAVE_VOLUME_SIZE'])
slave_instance_type = os.environ['SLAVE_INSTANCE_TYPE']
ec2_subnet_id = os.environ['EC2_SUBNET_ID']
ec2key_name = os.environ['EC2KEY_NAME']
master_sg = os.environ['MASTER_SG']
slave_sg = os.environ['SLAVE_SG']
service_access_sg = os.environ['SERVICE_ACCESS_SG']
cluster_name = os.environ['CLUSTER_NAME']
Release_Label = os.environ['RELEASE_LABEL']
bootstrap_path = os.environ['EMR_BOOTSTRAP_PATH']
step_sctips_path = os.environ['EMR_STEP_SCRIPTS_PATH']
env=os.environ['ENV']
script_runner_jar = 's3://us-east-1.elasticmapreduce/libs/script-runner/script-runner.jar'
bucket_name =''
dfs_replication = os.environ['DFS_REPLICATION']

#get bucket name from bootstrap path.
# eg.str="s3://p2d-poc/p2d/emr/bootstrap"
# tokens=str.split("/")
# print(tokens[2])
# p2d-poc (bucket name)
def get_bucket_name(bootstrap_path):
    tokens=bootstrap_path.split("/")
    return tokens[2]

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
    bucket_name = get_bucket_name(bootstrap_path)
    print("Bucket Name is :" + bucket_name)
    #create a cluster if one already not exists
    if not is_cluster_exists():
        print("Creating EMR")
        client = boto3.client('emr')
        region_name = os.environ['REG']
        print(event)
        cluster_id = client.run_job_flow(
            Name=cluster_name,
            LogUri=os.environ['EMR_LOGS_PATH'],
            ReleaseLabel=Release_Label,
            Applications=[
                {'Name': 'Ganglia'},
                {'Name': 'Zeppelin'},
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
                        # 'InstanceCount': 1,
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
                        'InstanceCount': slave_core_instance_count,
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
                # 'Ec2SubnetId': 'subnet-1592a34d'
                'EmrManagedMasterSecurityGroup': master_sg,
                'EmrManagedSlaveSecurityGroup': slave_sg,
                'ServiceAccessSecurityGroup': service_access_sg
            },
            # EMR BootStrapActions
            BootstrapActions=[
                {
                    'Name': 'Copy P2d Folder', 
                    'ScriptBootstrapAction': {
                        'Args':[bucket_name], 
                        'Path': bootstrap_path + '/download.sh'
                    }
                }
                
                
                
                
            ],
            Configurations=[{'Classification': 'hdfs-site',
                             'Properties': {'dfs.replication': dfs_replication}}],

            # EMR Steps
            Steps=[
                {
                    'Name': 'update-configuration',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/update_config.sh',env]
                    }
                },
                {
                    'Name': 'unzip_int_es_cmp_v3_1',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/unzip_int_es_cmp_v3.sh']
                    }
                },
                {
                    'Name': 'unzip_eha',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/unzip_eha.sh']
                    }
                },  
                {
                    'Name': 'IntEsCmpV3MasterDeltaMerge',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/mergeIntEsCmpV3.sh']
                    }
                },
                {
                    'Name': 'CopyMasterFromHdfsToS3 ',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/copy-master-hdfs-to-s3.sh']
                    }
                },
                {
                    'Name': 'CopyGtsDelta',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CopyGtsDelta.sh']
                    }
                },
                {
                    'Name': 'processGtsFullSeed ',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/ProcessGTSFullSeed.sh']
                    }
                },
				{
                    'Name': 'GtsMasterDeltaMerge ',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/GtsMasterDeltaMerge.sh']
                    }
                },
				{
                    'Name': 'copy-gtsmaster-hdfs-to-s3 ',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/copy-gtsmaster-hdfs-to-s3.sh']
                    }
                },
                {
                    'Name': 'GenerateMetadataRow',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/GenerateMetadataRow.sh']
                
                    }
                },	
            	{
                    'Name': 'ImportRawToParque',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/ImportRawToParquet.sh']
                
                    }
                },
				{
                    'Name': 'SOWChangeDetection',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,                    
                        'Args': [step_sctips_path + '/SOWChangeDetection.sh']
                
                    }
                },
                {
                    'Name': 'ImportGTSRawToParquet',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/ImportGTSRawToParquet.sh']
                
                    }
                },
                {
                    'Name': 'CreateCaseClassFromGTSModel',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CreateCaseClassFromGTSModel.sh']
                    }
                },
            	{
                    'Name': 'CreateCaseClassDelta',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CreateCaseClassDelta.sh',]
                    }
                },
                {
                    'Name': 'CleanseCaseClass',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CleanseCaseClass.sh']
                    }
                },
                {
                    'Name': 'CreateCompounds',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CreateCompounds.sh']
                    }
                },
                {
                    'Name': 'ImportRawToParqueEHA',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/ImportRawToParquetEha.sh']
                
                    }
                },
                {
                    'Name': 'CreateCaseClassEHA',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CreateCaseClassEha.sh']
                    }
                },              
                {
                    'Name': 'CleanseCaseClassEHA',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CleanseCaseClassEha.sh']
                    }
                },
                {
                    'Name': 'CreateCompoundsEHA',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CreateCompoundsEha.sh']
                    }
                },
            	{
                    'Name': 'CreateENGInput',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CreateENGInput.sh']
                    }
                },
                {
                    'Name': 'CreateENGInputEHA',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CreateENGInputEha.sh']
                    }
                },
                {
                    'Name': 'RunEng',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/EngConfig.sh']
                    }
                },
                {
                    'Name': 'CreateCleanseMaster',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/cleanseMasterData.sh']
                    }
                },
                {
                    'Name': 'CopyEngFromHdfsToS3',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/copy-hdfs-to-s3.sh']
                    }
                },
                {                                                     
                    'Name': 'LoadElastic',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/LoadElastic.sh']
                    }
                },
                {                                                     
                    'Name': 'DeleteFromElastic',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/DeleteFromElastic.sh']
                    }
                },
            	{                                                     
                    'Name': 'MarkRunComplete',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/MarkRunComplete.sh']
                    }
                },
                {                                                     
                    'Name': 'CreateJsonConfigJob',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/CreateJsonConfigJob.sh']
                    }
                },
                {                                                     
                    'Name': 'ResolvedCentricJsonUBOJob',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/ResolvedCentricJsonUBOJob.sh']
                    }
                },
                {
                    'Name': 'CopyClusterJsonFromHdfstoS3',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/copy-cluster-json-hdfs-to-s3.sh']
                    }
                },
                {                                                     
                    'Name': 'ClusterChangeDetectionJob',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/ChangeDetectionClusterCentric_UBO_Writes.sh']
                    }
                },
                {
                    'Name': 'CreateResolvedRoles',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/createJson.sh']
                    }
                },
                {
                    'Name': 'CreateOrganizationDetails',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/createJsonOrg.sh']
                    }
                },                
                {
                    'Name': 'DetectEntityChange',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/DetectEntityChange.sh']
                    }
                },
                {
                    'Name': 'CopyJsonFromHdfstoS3',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/copy-json-hdfs-to-s3.sh']
                    }
                },
                {
                    'Name': 'PrepareJsonToLoadElastic',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/PrepareJsonToLoadElastic.sh']
                    }
                },
                {
                     'Name': 'LoadJsonToElasticSearch',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/LoadJsonToElasticSearch.sh']
                    }
                },
                {                                                     
                    'Name': 'CreateMatrix',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/RolePlayerMatrixGenerator.sh']
                    }
                },
                {                                                     
                    'Name': 'ElasticBackup',
                    'ActionOnFailure': 'TERMINATE_CLUSTER',
                    'HadoopJarStep': {
                        'Jar': script_runner_jar,
                        'Args': [step_sctips_path + '/es_backup.sh',env]
                    }
                }
                
            ],
            AutoScalingRole='EMR_AutoScaling_DefaultRole',
            VisibleToAllUsers=True,
            JobFlowRole='EMR_EC2_DefaultRole',
            ServiceRole='EMR_DefaultRole',
            EbsRootVolumeSize=100,
            Tags=[
                {
                    'Key': 'NAME',
                    'Value': 'Emr_Spark',
                },
                {
                    'Key': 'Environment',
                    'Value': env,
                },
                {
                    'Key': 'CostCenter',
                    'Value': '9271',
                },
                {
                    'Key': 'ProjectName',
                    'Value': 'People to DUNS',
                },
                {
                    'Key': 'EnsonoSupportLevel',
                    'Value': 'co-managed',
                },
                {
                    'Key': 'Monitoring',
                    'Value': 'datadog',
                },
                {
                    'Key': 'Platform',
                    'Value': 'CentOS7',
                },
            ],
        )
        clusterId = cluster_id['JobFlowId']
        print ("Cluster:'" + cluster_name +"' is created with ClusterID:" + clusterId)
        
        print ("Setting Step failed couldwatch event for ClusterID:" + clusterId)
        # Create CloudWatchEvents client
        cloudwatch_events = boto3.client('events')
        cloudwatch_events.put_rule(
            Name="p2d-emr-state-change-" + env,
            EventPattern="""
            {
                "source": [
                    "aws.emr"
                ],
                "detail-type": [
                    "EMR Step Status Change"
                ],
                "detail": {
                    "state": [
                        "FAILED",
                        "COMPLETED"
                    ],
                    "clusterId": [ """ + "\"" + clusterId + "\"" + """ ]
                }
            } """,
            State="ENABLED"    
        )    
        print ("Cluster:'" + cluster_name +"' is created with ClusterID:" + cluster_id['JobFlowId'])
    else:
        print ("Cluster:'" + cluster_name +"' is already exists")
print('LogUri')

