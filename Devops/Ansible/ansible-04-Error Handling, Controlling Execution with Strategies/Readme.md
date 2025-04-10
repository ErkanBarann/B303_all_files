# Hands-on Ansible-04: Error handling and Controlling Execution with strategies in ansible

The purpose of this hands-on training is to give students the knowledge of best parctices in ansible playbooks.

## Learning Outcomes

At the end of this hands-on training, students will be able to;

- Explain how to make error handling in Ansible

- Explain how to control playbook execution in Ansible

## Outline

- Part 1 - Build the Infrastructure (3 EC2 Instances with Ubuntu 20.04 AMI)

- Part 2 - Install Ansible on the Controller Node

- Part 3 - Pinging the Target Nodes

- Part-4 - Error Handling and Controlling playbook execution: strategies

## Part 1 - Build the Infrastructure

- Get to the AWS Console and spin-up 3 EC2 Instances with ```Ubuntu 20.04``` AMI.

- Configure the security groups as shown below:

  - Controller Node ----> Port 22 SSH

  - Target Node1 -------> Port 22 SSH, Port 3306 MYSQL/Aurora

  - Target Node2 -------> Port 22 SSH, Port 80 HTTP

## Part 2 - Install Ansible on the Controller Node

- Run the terraform files in github repo.

- Connect to your ```Controller Node```.

- Optionally you can connect to your instances using VS Code.

- Check Ansible's installation with the command below.

```bash
$ ansible --version
```

- Show and exlain the files (`ansible.cfg`, `inventory.txt`) that created by terraform.

## Part 3 - Pinging the Target Nodes

- Make a directory named ```ansible-lesson``` under the home directory and cd into it.

```bash
mkdir ansible-lesson
cd ansible-lesson
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

## Part-4 Error Handling and Controlling playbook execution: strategies

This section focuses on error handling and controlling the execution of Ansible playbooks using various strategies.

Setup EC2 Instance and Create Playbook
Create EC2 Instance:

Launch a new EC2 instance (Amazon Linux 2, t2.micro) and add it to your Ansible inventory.

Create Playbook (playbook2.yml):

In this playbook, we will explore Ansible playbook strategies and error handling techniques.


```bash
- hosts: servers
  # any_errors_fatal: true
  # strategy: free
  # serial: 2
  tasks:
    - ansible.builtin.debug:
        msg: "task 1"

    - ansible.builtin.debug:
        msg: "task 2"

    # Our intention is to make node3 fail in the third task.
    - name: task 3
      become: true
      ansible.builtin.apt:
        name: git
        state: present
    #   ignore_errors: true

    - ansible.builtin.debug:
        msg: "task 4"

    - ansible.builtin.debug:
        msg: "task 5"
```
Run the Playbook:

```bash
ansible-playbook playbook2.yml
```
Expected Outcome:
In the playbook, we will encounter an error because the apt module is not supported on Amazon Linux 2 (Node3). The playbook cannot complete for Node3.

Error Handling
1. Using any_errors_fatal
If you want the playbook to stop when an error occurs in any task, use the any_errors_fatal parameter.

Command:

```bash
ansible-playbook playbook2.yml
```
Explanation: In the playbook, the apt module will fail because it's not supported on Amazon Linux 2. By default, the playbook continues even after the failure. If you want to stop the entire playbook execution when an error occurs in a target node, use any_errors_fatal.

Modify the Playbook:


```bash
- hosts: servers
  any_errors_fatal: true  # This stops the playbook when any error occurs
  tasks:
    - name: Task 1
      ansible.builtin.debug:
        msg: "This is Task 1"

    - name: Task 2
      ansible.builtin.debug:
        msg: "This is Task 2"

    - name: Task 3 (this will fail)
      ansible.builtin.apt:
        name: git
        state: present
      ignore_errors: false  # This task will fail, and the playbook will stop

    - name: Task 4 (this will not run)
      ansible.builtin.debug:
        msg: "This is Task 4"
```
Run the Playbook Again:
```bash
$ ansible-playbook playbook2.yml
```
Expected Outcome:

The playbook will stop after Task 3 fails, and Task 4 will not run because of the any_errors_fatal: true parameter.

2. Using ignore_errors
If you want the playbook to continue after an error occurs, use ignore_errors: true in the task that may fail.

```bash
ansible-playbook playbook2.yml
```
Modify the Playbook:

```bash
- hosts: servers
  tasks:
    - name: Task 1
      ansible.builtin.debug:
        msg: "This is Task 1"

    - name: Task 2
      ansible.builtin.debug:
        msg: "This is Task 2"

    - name: Task 3 (this will fail)
      ansible.builtin.apt:
        name: git
        state: present
      ignore_errors: true  # This allows the playbook to continue after failure

    - name: Task 4 (this will run)
      ansible.builtin.debug:
        msg: "This is Task 4"
```
Run the Playbook Again:

ansible-playbook playbook2.yml
Expected Outcome:

The playbook continues to run Task 4 even after Task 3 fails due to the ignore_errors: true parameter.

Execution Strategies
## 1. Using strategy: free
By default, Ansible runs tasks across all hosts in parallel. With the free strategy, tasks are executed independently on each host. If one host is stuck, it won't block the others.


ansible-playbook playbook2.yml
Modify the Playbook:

```bash
- hosts: servers
  strategy: free  # Tasks are executed independently on each host
  tasks:
    - name: Task 1
      ansible.builtin.debug:
        msg: "This is Task 1"

    - name: Task 2
      ansible.builtin.debug:
        msg: "This is Task 2"

    - name: Task 3 (this will fail on node3)
      ansible.builtin.apt:
        name: git
        state: present
      ignore_errors: true

    - name: Task 4
      ansible.builtin.debug:
        msg: "This is Task 4"
```
Run the Playbook Again:

ansible-playbook playbook2.yml
### Expected Outcome:

Task 3 will fail on node3 (due to the apt module not being supported), but the playbook continues running on the other nodes (Node1 and Node2) because the tasks are executed independently using the free strategy.

## 2. Using serial
The serial parameter allows you to control how many hosts are executed in parallel. By default, Ansible runs tasks across 5 hosts simultaneously. Using serial, you can process a specific number of hosts at once.

ansible-playbook playbook2.yml
Modify the Playbook:

```bash
- hosts: servers
  serial: 2  # This will process tasks in batches of 2 hosts at a time
  tasks:
    - name: Task 1
      ansible.builtin.debug:
        msg: "This is Task 1"

    - name: Task 2
      ansible.builtin.debug:
        msg: "This is Task 2"

    - name: Task 3
      ansible.builtin.debug:
        msg: "This is Task 3"

    - name: Task 4
      ansible.builtin.debug:
        msg: "This is Task 4"
```
Run the Playbook Again:

ansible-playbook playbook2.yml
### Expected Outcome:

The tasks will be executed in pairs. For example, if you have 6 hosts, tasks will run on Node1 and Node2 first, then Node3 and Node4, and so on.

## Combined Strategies
You can combine strategy: free with serial to run tasks on a specified number of hosts independently, but still in batches.

Modify the Playbook:


```bash
- hosts: servers
  strategy: free
  serial: 2  # Tasks will be executed independently, but in batches of 2
  tasks:
    - name: Task 1
      ansible.builtin.debug:
        msg: "This is Task 1"

    - name: Task 2
      ansible.builtin.debug:
        msg: "This is Task 2"

    - name: Task 3 (this will fail)
      ansible.builtin.apt:
        name: git
        state: present
      ignore_errors: true

    - name: Task 4
      ansible.builtin.debug:
        msg: "This is Task 4"
```
Run the Playbook Again:

ansible-playbook playbook2.yml
Expected Outcome:

This allows tasks to be executed independently on each host, but with a limit of 2 hosts per batch, ensuring more control over parallel execution.

#### Error Handling:

any_errors_fatal

ignore_errors

#### Execution Strategies:

strategy: free

serial

These strategies allow for flexible and controlled execution of tasks across multiple hosts in a distributed system, ensuring that Ansible playbooks can handle errors and parallel execution efficiently.