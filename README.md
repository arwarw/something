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
gcloud projects add-iam-policy-binding ${PROJECT_ID} --member=serviceAccount:terraform-service-account@${PROJECT_ID}.iam.gserviceaccount.com --role=roles/compute.admin --role=roles/storage.admin --role=roles/container.admin
```

Put the credentials file and project ID somewhere terraform can use it.
```
if [ ! -f tf/terraform.tfvars ] ; then
    echo "gcp_credentials_file = "~/.gcloud/${PROJECT_ID}.json" >> tf/terraform.tfvars
    echo "gcp_project = "${PROJECT_ID}" >> tf/terraform.tfvars
fi
```

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

