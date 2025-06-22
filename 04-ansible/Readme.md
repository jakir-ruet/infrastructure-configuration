## Ansible Server Install and configuration

### Install Ansible

```bash
apt update
apt install software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible
ansible --version
```

#### Active the bash completion support we may install these (If needed)

```bash
apt install python3-argcomplete
activate-global-python-argcomplete3
```

### Create `directory` and `ansadmin` in ansible server

```bash
mkdir /etc/ansible # if not available
useradd ansadmin
passwd ansadmin
id ansadmin
sudo mkdir -p /home/ansadmin
sudo chown ansadmin:ansadmin /home/ansadmin
```

### Add this user in `sudoers` file

```bash
cat /etc/sudoers
visudo
ansadmin ALL=(ALL) NOPASSWD: ALL
```

## Install using the apt repository

```bash
# Add Docker's official GPG key:
sudo apt-get update
sudo apt-get install ca-certificates curl
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc

# Add the repository to Apt sources:
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt-get update
```

### Docker Install

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Add the user `ansadmin` to `docker` group

```bash
cat /etc/group # check group
usermod -aG docker ansadmin
id ansadmin # check group
```

### Change `PasswordAuthentication yes`, default `PasswordAuthentication yes` we need `yes`

```bash
vi /etc/ssh/sshd_config
PasswordAuthentication yes
systemctl restart ssh
```

### How to switch `$ to ansadmin@docker-server`

```bash
getent passwd ansadmin
ansadmin:x:1001:1001::/home/ansadmin:/bin/bash  # should see
ansadmin:x:1001:1001::/home/ansadmin:/bin/sh # not should see, then run
sudo usermod -s /bin/bash ansadmin
sudo su - ansadmin
```

### Create `ssh-key`

```bash
ssh-keygen
pwd
/home/ansadmin
ls -la
cd .ssh/
ls -la
```

### Go back docker server and create same user name `ansadmin` and same `password` I as created on ansible server

```bash
cat /etc/group # check docker group
useradd ansadmin
passwd ansadmin
id ansadmin
sudo mkdir -p /home/ansadmin
sudo chown ansadmin:ansadmin /home/ansadmin
```

How to switch `$ to ansadmin@docker-server`

```bash
getent passwd ansadmin
ansadmin:x:1001:1001::/home/ansadmin:/bin/bash  # should see
ansadmin:x:1001:1001::/home/ansadmin:/bin/sh # not should see, then run
sudo usermod -s /bin/bash ansadmin
sudo su - ansadmin
```

### Copy key of docker server

```bash
sudo su - ansadmin
ssh-copy-id ansadmin@docker-server-private-ip
ssh-copy-id ansadmin@192.168.1.111
yes # first time its ask password
```

### Login - user `ansadmin` user

```bash
ssh ansadmin@docker-server-private-ip
ssh ansadmin@192.168.1.111 # It should jamp `Ansible` server to `Docker`
```

### Now make sure ping test of `docker` server from `ansible` server

Work in Ansible Server under root user

```bash
cd /home/ansible
vi hosts
[web]
192.168.1.11 # docker server ip
localhost # Mean ansible server
ansible all -m ping # or
ansible all -i hosts -m ping
```
