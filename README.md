# tasktap

## About

Build custom OS image, build multiple VMs, creates a Docker swarm and deploys tasktap stack.

Basic Debian 12 created with Packer.
1 manager, 5 worker and 1 storage VM created with Terraform.
Docker Swarm init and stack deployment made with Ansible.

Each VM uses 2 CPUs and 1024 Mb RAM.

The stack yaml location: ```ansible-playbook/roles/deploy/stacks/tasktap```
The app, database and phpmyadmin services run on worker nodes.
The frotnendproxy runs on the manager.
The app's 5 replicas run on separate worker nodes.
The stack in located on the storage VM and mounted via NFS to the other VMs.

## Setup the environment

The following steps asume the host runs Debian

### Install Packer, Terraform, Ansible, Qemu/KVM and libvirt

Run the command below:
```
apt update
apt install -y gnupg software-properties-common
curl -fsSL https://apt.releases.hashicorp.com/gpg | apt-key add -
apt-add-repository "deb [arch=amd64] https://apt.releases.hashicorp.com $(lsb_release -cs) main"
apt update
apt install -y terraform packer ansible ansible-core qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst libvirt-daemon
```

Note: Terraform migth not be able to create VMs due to permission denied. To fix it, edit the ```/etc/libvirt/qemu.conf``` file at:
```
#security_driver = "selinux"
```
and change it to:
```
security_driver = "none"
```

Dont forget to restart related services

## Create disk image, VMs and the Swarm

### Create disk image

1) Generate ssh keypair named packer_key

```
ssh-keygen
```

After that, edit the ```http/preseed.conf``` file at the end to place your pubkey under root's authorized_keys.

When accessing VMs later, use the following command:
```
ssh -i /path/to/.ssh/private root@vm.local
```

Note: If your ssh key has not passphrase, you can use it, but change the ```ssh_private_key_file``` var's value.

2) Run script to build image

@param1: packer output dir
@param2: final destination, should be ```/var/lib/libvirt/images```
@param3: vm_name, name of OS image

```
cd packer/
./run.sh @param1 @param2 @param3
cd ..
```

The script init and build the packer project then copies the OS image to libvirt's env and deletes the output dir to allow re-run.

### Create VMs

1) Edit ```/etc/hosts```

If this project is about to be run locally, create the following domain entries:
```
10.0.40.100	manager-0.home.lab
10.0.40.110	worker-0.home.lab
10.0.40.111	worker-1.home.lab
10.0.40.112	worker-2.home.lab
10.0.40.113	worker-3.home.lab
10.0.40.114	worker-4.home.lab
10.0.40.200	storage.home.lab

10.0.40.100	tasktap.local
10.0.40.100	phpmyadmin.local
```

Note: edit network.tf if 10.0.40.0/24 is already used elsewhere

2) Init terraform project

```
terraform init
```

3) Install Ansible collection

For dynamically generated inventory:
```
ansible-galaxy collection install cloud.terraform
```

4) Apply terraform

```
terraform plan
terraform apply -auto-approve
```

### Run Ansible

To create the swarm and deploy ```tasktap```:
```
ansible-playbook -i ./inventory.yaml --diff ansible-playbook/swarm.yaml
```

## Testing, upgrading image

### Run client.sh

```
./client.sh
```

### Check browser

A browser should load ```tasktap.local/server.php?op=info``` page. Visit ```phpmyadmin.local``` to check database, and the results of ```./client.sh```.

### Upgrade the image

Change app_image var's value at ```ansible-playbook/roles/deploy/default/main.yml``` then re-run the playbook.
