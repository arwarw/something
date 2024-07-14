# Technical Assignment

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

