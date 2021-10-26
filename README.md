# Deployment and Operations of MinIO Object Storage with Cisco Intersight Appliance and Terraform

------

The repository is for an automated deployment of MinIO Object Storage on Cisco UCS with Terraform Infrastructure as Code. It covers three main steps:

- Creation of policies and profiles for Cisco UCS C240 M5L
- Deployment of profiles
- Installation of RHEL 8.4 operating system

The repository is based on the published White Paper.

The solution setup consists of multiple parts. It covers basic setup of the network components, policies, and profiles, and installations of various parts as well. It shows typical Day-2 operations with Cisco Intersight and Terraform and a basic performance and high-availability testing. The high-level flow of the solution setup follows:

1. Install and configure Cisco UCS C240 M5 with Cisco Intersight and Terraform provider for Cisco Intersight.
2. Deploy Red Hat Enterprise Linux and MinIO.
3. Perform functional tests of the whole solution.
4. Expand MinIO cluster with disks, nodes, and network ports through Cisco Intersight and Terraform.
5. Replace a failed disk.

![alt text](https://github.com/owalsdor/Intersight_Terraform_MinIO_Day2/blob/master/terraform_overview.jpg?raw=true)

## Usage

------

The usage of the repository is very simple. The steps are:

- Create an Cisco Intersight API key and store it in your directory
- Edit the variables.tf file in one directory of terraform-minio with your data and copy the file to the other directories
- Go to the first directory terraform-minio/create_policy_profile and run "terraform apply" after "terraform init"
- When all policies and profiles got created then go to terraform-minio/deploy_profile and deploy the formerly created profiles
- After the profiles got deployed then go to terraform-minio/install_os and install the operating system.

For more details please refer to [link of WP]