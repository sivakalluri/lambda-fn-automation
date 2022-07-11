# MASTER INSTANCE COUNT
variable "MASTER_INSTANCE_COUNT" {
  description = "Count of Master instances"
  type = number
}

# MASTER VOLUME SIZE
variable "MASTER_VOLUME_SIZE" {
  description = "Size of Master instances"
  type = number
}

# MASTER INSTANCE TYPE
variable "MASTER_INSTANCE_TYPE" {
  description = "Instance type of Master instances"
  type = string
}

# SLAVE INSTANCE COUNT
variable "SLAVE_INSTANCE_COUNT" {
  description = "Count of Slave Instances"
  type = number
}

# SLAVE VOLUME SIZE
variable "SLAVE_VOLUME_SIZE" {
  description = "Size of Slave instances"
  type = number
}

# SLAVE INSTANCE TYPE
variable "SLAVE_INSTANCE_TYPE" {
  description = "Instance type of Slave instances"
  type = string
}

# EC2 SUBNET ID
variable "EC2_SUBNET_ID" {
  description = "Subnet ID for EC2 Instances"
}

# EC2KEY_NAME
variable "EC2KEY_NAME" {
  description = "EC2 Key Name for EC2 instances"
}

# Master Security Group
variable "MASTER_SG" {
  description = "Security Group for Master instances"
}

# SLAVE Security Group
variable "SLAVE_SG" {
  description = "Security Group for Slave instances"
}

# SERVICE ACCESS SG
variable "SERVICE_ACCESS_SG" {
  description = "SG for Service Access"
  type = string
}

# CLUSTER_NAME
variable "CLUSTER_NAME" {
  description = "Name of Cluster"
}

# RELEASE LABEL
variable "RELEASE_LABEL" {
  description = "Release Label"
}

# EMR BOOTSTRAP PATH
variable "EMR_BOOTSTRAP_PATH" {
  description = "EMR Bootstrap Path"
}

# EMR STEP SCRIPTS PATH
variable "EMR_STEP_SCRIPTS_PATH" {
  description = "EMR Step Scripts Path"
}

# ENV
variable "ENV" {
  description = "Environment"
}

# DFS REPLICATION
variable "DFS_REPLICATION" {
  description = "DFS REPLICATIONL"
}
