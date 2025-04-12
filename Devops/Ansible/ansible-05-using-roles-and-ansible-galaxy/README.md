# Hands-on Ansible-05 : Using Roles
The purpose of this hands-on training is to give students knowledge of basic Ansible skills.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Explain what is Ansible role
- Learn how to create, find and use a role.  

## Outline

- Part 1 - Install Ansible

- Part 2 - Using Ansible Roles 

- Part 3 - Using Ansible Roles from Ansible Galaxy

## Part 1 - Install Ansible

- Create 3 Amazon Linux 2023 and 1 Ubuntu EC2 instances. Then name the instances as below. For Security Group, allow ssh and http when creating EC2.
1-control-node
2-node1
3-node2
4-node3 (ubuntu)

- Connect to the control node with SSH and run the following commands.

- export PS1='\[\033[1;34m\]\u@\h\[\033[0m\]:\[\033[1;32m\]\w\[\033[0m\] \[\033[1;33m\](⚡Ansible)\[\033[0m\]\n\$ '

```bash
sudo dnf update -y
curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
python3 get-pip.py --user
pip3 install --user ansible
```
### Confirm Installation

- To confirm the successful installation of Ansible. You can run the following command.

```bash
ansible --version
```
### Configure Ansible on AWS EC2

- Connect to the control node and create an inventory.

- Make a directory named ```working-with-roles``` under the home directory and cd into it.

```bash 
mkdir working-with-roles
cd working-with-roles
```

```bash
vim inventory.txt
```
```bash
[webservers]
node1 ansible_host=<node1_ip> ansible_user=ec2-user
node2 ansible_host=<node2_ip> ansible_user=ec2-user

[ubuntuservers]
node3 ansible_host=<node3_ip> ansible_user=ubuntu

[all:vars]
ansible_ssh_private_key_file=/home/ec2-user/<pem file>
```

- Create an  `ansible.cfg` file under `/home/ec2-user` folder as below. 

```bash
vim ansible.cfg
[defaults]
host_key_checking = False
inventory = inventory.txt
deprecation_warnings=False
interpreter_python=auto_silent
roles_path = /home/ec2-user/ansible/roles/
```

- Copy your pem file to the `/home/ec2-user` directory. First go to your pem file directory on your local computer and run the following command.

```bash
scp -i <pem file> <pem file> ec2-user@<public DNS name of the control node>:/home/ec2-user
```

- or you can create a file name <pem file> into the directory `/home/ec2-user` on the control node and copy your pem file into it.

- Create a file named ```ping-playbook.yml``` and paste the content below.

```bash
touch ping-playbook.yml
```

```yml
- name: ping them all
  hosts: all
  tasks:
    - name: pinging
      ansible.builtin.ping:
```

- Run the command below for pinging the servers.

```bash
ansible-playbook ping-playbook.yml
```

- Explain the output of the above command.

## Part 2 - Using Ansible Roles

- Install apache server and restart it with using Ansible roles.

```bash
ansible-galaxy init /home/ec2-user/ansible/roles/apache
```

```bash
cd /home/ec2-user/ansible/roles/apache
ls -al
sudo dnf install tree -y
tree
```

- Create `tasks/main.yml` with the following.

vi tasks/main.yml

```yml
- name: installing apache
  ansible.builtin.yum:
    name: httpd
    state: latest

- name: index.html
  ansible.builtin.copy:
    content: "<h1>Hello Techproed</h1>"
    dest: /var/www/html/index.html

- name: restart apache2
  ansible.builtin.service:
    name: httpd
    state: restarted
    enabled: yes
```

- Create a playbook named `role1.yml`.

```bash
cd /home/ec2-user/working-with-roles/
vim role1.yml
```

```yml
---
- name: Install and Start apache
  hosts: node1
  become: yes
  roles:
    - apache
```

- Run the command below 

```bash
ansible-playbook role1.yml
```

## Part 3 - Using Ansible Roles from Ansible Galaxy

- Go to Ansible Galaxy web site https://galaxy.ansible.com/ui/search/

- Click the Search option

- Write `nginx`

- Explain the difference beetween collections and roles

- Evaluate the results (stars, number of download, etc.)

- Go to command line and write:

```bash
ansible-galaxy search nginx


Stdout:

Found 1494 roles matching your search. Showing first 1000.

 Name                                                         Description
 ----                                                         -----------
 0x0i.prometheus                                              Prometheus - a multi-dimensional time-series data mon
 0x5a17ed.ansible_role_netbox                                 Installs and configures NetBox, a DCIM suite, in a pr
 1davidmichael.ansible-role-nginx                             Nginx installation for Linux, FreeBSD and OpenBSD.
 1it.sudo                                                     Ansible role for managing sudoers
 1mr.zabbix_host                                              configure host zabbix settings
 1nfinitum.php                                                PHP installation role.
 2goobers.jellyfin                                            Install Jellyfin on Debian.
 2kloc.trellis-monit                                          Install and configure Monit service in Trellis.
 ```

- there are lots of. Lets filter them.

```bash
ansible-galaxy search nginx --platform EL
```
"EL" for centos 

- Lets go more specific :

```bash
ansible-galaxy search nginx --platform EL | grep geerl

Stdout:

geerlingguy.nginx                                            Nginx installation for Linux, FreeBSD and OpenBSD.
geerlingguy.php                                              PHP for RedHat/CentOS/Fedora/Debian/Ubuntu.
geerlingguy.pimpmylog                                        Pimp my Log installation for Linux
geerlingguy.varnish                                          Varnish for Linux.
```
- Install it:

```bash
ansible-galaxy install geerlingguy.nginx

Stdout:

Starting galaxy role install process
- downloading role 'nginx', owned by geerlingguy
- downloading role from https://github.com/geerlingguy/ansible-role-nginx/archive/3.2.0.tar.gz
- extracting geerlingguy.nginx to /home/ec2-user/ansible/roles/geerlingguy.nginx
- geerlingguy.nginx (3.2.0) was installed successfully
```

- Inspect the role:

```bash
cd /home/ec2-user/ansible/roles/geerlingguy.nginx
ls

stdout:

LICENSE  README.md  defaults  handlers  meta  molecule  tasks  templates  vars

cd tasks
ls

main.yml             setup-Debian.yml   setup-OpenBSD.yml  setup-Ubuntu.yml
setup-Archlinux.yml  setup-FreeBSD.yml  setup-RedHat.yml   vhosts.yml
```
```bash
vim main.yml
```
```yml
---
# Variable setup.
- name: Include OS-specific variables.
  include_vars: "{{ ansible_os_family }}.yml"

- name: Define nginx_user.
  set_fact:
    nginx_user: "{{ __nginx_user }}"
  when: nginx_user is not defined

# Setup/install tasks.
- include_tasks: setup-RedHat.yml
  when: ansible_os_family == 'RedHat'

- include_tasks: setup-Ubuntu.yml
  when: ansible_distribution == 'Ubuntu'

- include_tasks: setup-Debian.yml
  when: ansible_os_family == 'Debian'

- include_tasks: setup-FreeBSD.yml
  when: ansible_os_family == 'FreeBSD'

- include_tasks: setup-OpenBSD.yml
  when: ansible_os_family == 'OpenBSD'

- include_tasks: setup-Archlinux.yml
  when: ansible_os_family == 'Archlinux'

# Vhost configuration.
- import_tasks: vhosts.yml

# Nginx setup.
- name: Copy nginx configuration in place.
  template:
    src: "{{ nginx_conf_template }}"
    dest: "{{ nginx_conf_file_path }}"
    owner: root
    group: "{{ root_group }}"
    mode: 0644
  notify:
    - reload nginx
```

- # use it in playbook:

- Create a playbook named `playbook-nginx.yml`

```yml
- name: use galaxy nginx role
  hosts: node2
  become: true

  roles:
    - geerlingguy.nginx
```

- Run the playbook.

```bash
cd
cd working-with-roles
ansible-playbook playbook-nginx.yml
```

- List the roles you have:

```bash
ansible-galaxy list

Stdout:

# /home/ec2-user/ansible/roles
- apache, (unknown version)
- geerlingguy.nginx, 3.2.0
```

# Optional

* Assume that we need to create an custom AMI. At this AMI we want to use some software such as docker and prometheus. So in our project, every instance will be created with this AMI. We are also planning to update this AMI every 6 months. So we can update docker and prometheus software versions after 6 months. We need to re-usable configs to do that. Lets talk about this situation.


* First install git to Control Node:

```bash
sudo dnf install git -y
```

* Create a file which name is `role_requirements.yml`:

```yml
- src: git+https://github.com/geerlingguy/ansible-role-docker
  name: docker
  version: 2.9.0

- src: git+https://github.com/geerlingguy/ansible-role-ntp
  version: 2.1.0
  name: ansible-role-ntp

- src: git+https://github.com/UnderGreen/ansible-prometheus-node-exporter
  version: master
```

* We will use prometheus at next session to monitor our instances, and NTP is Network Time Protocol. [For more information](https://en.wikipedia.org/wiki/Network_Time_Protocol)

Then run this command:

```bash
ansible-galaxy install -r role_requirements.yml
```

* Check all the roles are created.

* Additionally create a role named with common:

```bash
ansible-galaxy init /home/ec2-user/ansible/roles/common
```

* Then create a playbook file to create instance image.
 `playbook.yml`
```yml
---
- hosts: node3
  become: yes
  become_method: sudo  

  roles:
    - common
    - { role: ansible-role-ntp, ntp_timezone: UTC }
    - docker
    - ansible-prometheus-node-exporter
```

* When you get ntp error, go and customize common role from ansible/roles/common/tasks/main.yml

```yml
---
# tasks file for /home/ec2-user/ansible/roles/common/tasks/main.yml:
- name: Common Tasks
  ansible.builtin.debug:
    msg: Common Task Triggered

- name: Fix dpkg
  ansible.builtin.command: dpkg --configure -a 

- name: Update apt
  ansible.builtin.apt:
    upgrade: dist
    update_cache: yes

- name: Install packages
  ansible.builtin.apt:
    name: "{{ item }}"
    state: present
  with_items:
    - ntp
```
```bash
ansible-playbook playbook.yml
```
* Also add a slack notification that shows ansible deployment is finished. 
`playbook.yml`
```yml
---
- hosts: node3
  become: yes
  become_method: sudo  

  roles:
    - common
    - { role: ansible-role-ntp, ntp_timezone: UTC }   
    - docker
    - ansible-prometheus-node-exporter

  tasks:
   - ansible.builtin.import_tasks: './slack.yml'    
```

./slack.yml is like:

```yml
---
- name: Send slack notification
  slack:
    token: "{{slack_token}}"
    msg: ' {{ inventory_hostname }} Deployed with Ansible ---> B303 DevOps' 
    # msg: '[{{project_code}}] [{{env_name}}] {{app_name}} {{ inventory_hostname }} {{aws_tags.Name}} '
    channel: "{{slack_channel}}"
    username: "{{slack_username}}"
  delegate_to: localhost
  run_once: true
  become: no
  when: inventory_hostname == ansible_play_hosts_all[-1]
  vars:
    slack_token: "YOUR/TOKEN"
    slack_channel: "#live_channel"
    slack_username: "Ansible-B303"
```
```bash
ansible-playbook playbook.yml
```
* Then run the playbook command again.
