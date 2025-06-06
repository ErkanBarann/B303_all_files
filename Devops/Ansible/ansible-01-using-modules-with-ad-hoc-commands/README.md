# Hands-on Ansible-01: To Install Ansible and Ansible Basic Operations

The purpose of this hands-on training is to give students knowledge of basic Ansible skills.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Explain what Ansible can do
- Learn basic Ad-hoc commands  

## Outline

- Part 1 - Install Ansible

- Part 2 - Ansible Ad-hoc Commands

## Part 1 - Install Ansible


- Spin-up 3 Amazon Linux 2023 instances(t2.micro) and name them as:
    1. control node
    2. node1 ----> (SSH PORT 22, HTTP PORT 80)
    3. node2 ----> (SSH PORT 22, HTTP PORT 80)


- Connect to the control node via SSH and run the following commands.

- export PS1='\[\033[1;34m\]\u@\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\] \[\033[1;33m\](⚡Ansible)\[\033[0m\]\n\$ '

```bash
sudo dnf update -y
sudo dnf install ansible -y
sudo hostnamectl set-hostname control-node
bash
```

### Confirm Installation

- To confirm the successful installation of Ansible, run the following command.

```bash
ansible --version
```
Stdout:
```
ansible [core 2.15.3]
  config file = None
  configured module search path = ['/home/ec2-user/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /usr/lib/python3.9/site-packages/ansible
  ansible collection location = /home/ec2-user/.ansible/collections:/usr/share/ansible/collections
  executable location = /usr/bin/ansible
  python version = 3.9.16 (main, Jul  5 2024, 00:00:00) [GCC 11.4.1 20230605 (Red Hat 11.4.1-2)] (/usr/bin/python3.9)
  jinja version = 3.1.4
  libyaml = True
```
- Explain the lines above:
    1. Version Number of Ansible
    2. Path for the Ansible Config File
    3. Modules are searched in this order
    4. Ansible's Python Module path
    5. Ansible's executable file path
    6. Ansible's Python version with GNU Compiler Collection for Red Hat

### Configure Ansible on the Control Node

- Connect to the control node for building a basic inventory.

- Edit ```/etc/ansible/hosts``` file by appending the connection information of the remote systems to be managed.

- Along with the hands-on, public or private IPs can be used.

```bash
cd /etc/ansible
ls
sudo vim hosts
[webservers]
node1 ansible_host=<node1_ip> ansible_user=ec2-user
node2 ansible_host=<node2_ip> ansible_user=ec2-user

[all:vars]
ansible_ssh_private_key_file=/home/ec2-user/<pem file>
```
Esc:wq

- Explain what ```ansible_host```, ```ansible_user``` and ```ansible_ssh_key_file``` parameters are. For this reason visit the Ansible's [inventory parameters web site](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#connecting-to-hosts-behavioral-inventory-parameters).

- Explain what an ```alias``` (node1 and node2) is and where we use it.

- Explain what ```[webservers] and [all:vars]``` expressions are. Elaborate the concepts of [group name](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#inventory-basics-formats-hosts-and-groups), [group variables](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#assigning-a-variable-to-many-machines-group-variables) and [default groups](https://docs.ansible.com/ansible/latest/user_guide/intro_inventory.html#default-groups). 

- Visit the above links for helping to understand the subject. 

- Copy your pem file to the Control Node. First, go to your pem file directory on your local PC and run the following command.

```bash
scp -i <pem file> <pem file> ec2-user@<public DNS name of Control Node>:/home/ec2-user
```
```bash
cd
chmod 400 <pem file>
```
- Check if the file is transferred to the remote machine. 

- As an alternative way, create a file on the control node with the same name as the <pem file> in ```/etc/ansible``` directory. 

- Then copy the content of the pem file and paste it in the newly created pem file on the control node.

## Part 2 - Ansible Ad-hoc Commands

- To confirm that all our hosts are located by Ansible, we will run the commands below.

```bash
ansible all --list-hosts
ansible webservers --list-hosts
```

- To make sure that all our hosts are reachable, we will run various ad-hoc commands that use the ping module.

```bash
ansible all -m ping
ansible webservers -m ping
ansible node1 -m ping
```
- Explain the content of the output. 

- Go back to the hosts file and change an ip address for showing the negative output.


### Let's Run Some Ad-hoc Commands

- "ansible-doc <module_name>" command is used for seeing the explanation and examples of a specific module.
 
- Run the below command.

```bash
ansible-doc ping
q
```
- Emphasize that the successful pinging returns ```pong``` answer. 

- Ask students how it is possible to ping without opening the ICMP port.

- Show how the ```ansible-doc ping``` command's explanation clarifies the above question.

- Run the command below.

```bash
ansible all -m ping -o
```

- Explain what ```-o``` option does.(one-line output)

- Emphasize the warning about the deprication of the usage of Python2.

- Go on with the following operations to get rid of the warning.

- Add the following lines to ```/etc/ansible/ansible.cfg``` file. 
```bash
sudo vim /etc/ansible/ansible.cfg
```
[defaults]
interpreter_python=auto_silent   

host_key_checking = False  
```

- Run the command below.

```bash
ansible --help
```

- Show ```-o``` option on the screen. Also show the meanings of ```-a, -m, -i, --list-hosts, --become-user```.

- Run the command below.

```bash
ansible webservers -a "uptime"
web_server1 | CHANGED | rc=0 >>
 13:00:59 up 42 min,  1 user,  load average: 0.08, 0.02, 0.01
```
- Explain how much the system is up and what is load avarage.

- Numbers for load avarage respectively mean (

load average over the last 1 minute: 8%

load average over the last 5 minutes: 2%

load average over the last 15 minutes: 1%

)

- Run the command below.

```bash
ansible webservers -m shell -a "systemctl status sshd"
```
- Explain the output.

- Run the command below.
```bash
ansible webservers -m command -a 'df -h'
```
- Then run the same command without ```-m command``` part.

```bash
ansible webservers -a 'df -h'
```

- Mention about the fact that the default ad-hoc module is the command module.

- Run the commands below for explaining how to transfer a file.

```bash
cd
vim testfile    # Create a text file name "testfile"
  "This is a test file."
esc:wq
```

```bash
ansible all -m copy -a "src=/home/ec2-user/testfile dest=/home/ec2-user/testfile"
ansible node1 -m shell -a "echo Hello techproed > /home/ec2-user/testfile2 ; cat testfile2"
ansible all -m shell -a "ls ; cat test*"
```

- Connect to Node1 and show the files and their content.

### Go on with Ubuntu 

- Spin up an Ubuntu EC2 instance. ----> (SSH PORT 22, HTTP PORT 80)

- Append the ip to the hosts file as shown below. 

```bash
sudo vim /etc/ansible/hosts
```
```bash
[ubuntuserver]
node3 ansible_host=<node3_ip> ansible_user=ubuntu
```

- Run the commands below.

```bash
ansible all --list-hosts
ansible all -m ping -o
ansible all -m shell -a "echo Hello techproed > /home/ubuntu/testfile3"
```

- Explain the error below. Emphasize that the infrastructures we provision need different configurations.

```bash
node3 | CHANGED | rc=0 >>
node1 | FAILED | rc=1 >>
/bin/sh: line 1: /home/ubuntu/testfile3: No such file or directorynon-zero return code
node2 | FAILED | rc=1 >>
/bin/sh: line 1: /home/ubuntu/testfile3: No such file or directorynon-zero return code
```

- So refactor the commands as shown below.

```bash
ansible node3 -m shell -a "echo Hello techproed > /home/ubuntu/testfile3"
ansible node1:node2 -m shell -a "echo Hello techproed > /home/ec2-user/testfile3"
```

- Emphasize the ```:``` sign between the hosts.


### Using Shell Module

- Run the command below.

```bash
ansible webservers -b -m shell -a "dnf install -y nginx ; systemctl start nginx ; systemctl enable nginx" 
```

- Run the commands below for Ubuntu server

```bash
ansible node3 -b -m shell -a "apt update -y ; apt-get install -y nginx ; systemctl start nginx; systemctl enable nginx"
```

- Visit both of the ip addresses to see the default nginx pages.

- Run the command below to remove the nginx package.

```bash
ansible webservers -b -m shell -a "dnf -y remove nginx"
```

### Using Yum and Package Module

- Run the command below.

```bash
ansible-doc yum
```

- Emphasize the description part of the yum command.

- Show the examples part of the result page.

- Emphasize the fact that these examples are given to be used in ```playbook files```.

- Run the command below ```twice```.

```bash
ansible webservers -b -m yum -a "name=nginx state=present"    
```

-  Explain the difference of the standard outputs. Emphasize the changes in color and ```changed``` property together with idempotency. 

- Run the command below.

```bash
ansible -b -m package -a "name=nginx state=present" all
ansible -b -m package -a "name=nginx state=absent" all

```

- Connect to nodes and check if nginx was installed. (nginx -v)

- Explain the difference of ```yum``` and ```package``` modules.


### Using Your Own Inventory

- Create a file named ```inventory```. 

- Edit the file as shown below:

```bash
vim inventory
```
```bash

[webservers]
web1 ansible_host=<node1_ip> ansible_user=ec2-user

[webservers:vars]
ansible_ssh_private_key_file=/home/ec2-user/<YOUR-PEM-FILE-NAME>.pem
```

- Install/uninstall Apache server to node1.

```bash
ansible -i inventory -b -m yum -a "name=httpd state=present" web1 
ansible -i inventory -b -m systemd -a "name=httpd state=started enabled=yes" web1
ansible -i inventory -b -m yum -a "name=httpd state=absent" web1 
```
