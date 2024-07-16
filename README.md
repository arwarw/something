# Technical Assignment

## Usage

```
git clone <this project>
cd <this project>
```

This uses Google Cloud Platform, so you need terraform and the corresponding
GCP provider installed.

Then pick a project ID. The first line will do that automatically, but you can
edit it if you like. The project ID needs to be unique, so there could be a
retry necessary if it is already taken.
```
export PROJECT_ID="something-${RANDOM}"
gcloud projects create $PROJECT_ID  # retry the first two lines if this fails
gcloud config set project $PROJECT_ID
```

Create a service account for terraform to use, and give it some permissions.
```
gcloud iam service-accounts create terraform-service-account
gcloud iam service-accounts keys create ~/.gcloud/${PROJECT_ID}.json --iam-account terraform-service-account@${PROJECT_ID}.iam.gserviceaccount.com
for i in roles/serviceusage.serviceUsageAdmin roles/compute.admin roles/storage.admin roles/container.admin roles/iam.serviceAccountUser ; do
    gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:terraform-service-account@${PROJECT_ID}.iam.gserviceaccount.com --role=$i
done
gcloud services enable cloudresourcemanager.googleapis.com # other services will be enabled by terraform, but that one can't be
```

Put the credentials file and project ID somewhere terraform can use it.
```
if [ ! -f tf/terraform.tfvars ] ; then
    touch tf/terraform.tfvars
    echo "gcp_credentials_file = \"~/.gcloud/${PROJECT_ID}.json\"" >> tf/terraform.tfvars
    echo "gcp_project = \"${PROJECT_ID}\"" >> tf/terraform.tfvars
else
    echo "not overwriting existing file, please edit manually to use PROJECT_ID ${PROJECT_ID}"
fi
```

You need to associate a GCP billing account with the project, but a budget of 0
is sufficient. A billing account needs to be created in the GCP cloud console
(https://console.cloud.google.com/billing). Your account ID will look something
like 123456-AB3456-123456. Associate this billing account ID with the new
project:

```
gcloud billing projects link $PROJECT_ID --billing-account=123456-AB3456-123456 # <- insert your real billing account id here
```

Initialize your terraform (if necessary).
```
terraform init
```

Plan and apply the terraform config
```
terraform apply
```
If you are doing this for the first time(s) this might need a few retries.
Enabling all GCP services for the first time in a project is asynchronous and
takes some time, meanwhile you will get corresponding API errors.

## Requirements
- Spin Up a Ubuntu VM with Terraform that has two interfaces: one external
  Interface and one Internal Interface.
- The internal Interface is connected to a device (10.200.16.100/29) that
  will need access to your VM on port 9000 TCP.
- Your VM and the device are connected to vswitch's ports that only accept
  vlan tagged packets with the vlan ID 150 for the internal interface.
- The external interface is exposed to the internet with any IP you choose.
- Using ansible Install and configure a Web- and SSH-Server that listens
  only on the external interface.
- Secure the server with Ansible.
- Upload your Terraform and Ansible code in a Github/GitLab repository and
  describe in its Readme the Steps we need to follow to run your code.
  Further describe your intentions you want to achieve with your Code. Share
  your Repository with us

