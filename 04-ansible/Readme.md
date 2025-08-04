# Ansible Install & connect `Ansible` server to `Docker` server

## Ansible Server Install and configuration

### Install Ansible

**On Ansible Machine** - under `root` user

```bash
apt update
apt install software-properties-common
apt-add-repository --yes --update ppa:ansible/ansible
apt install ansible
ansible --version
```

**On Ansible Machine** - under `root` user

#### Active the bash completion support we may install these (If needed)

```bash
sudo apt update
sudo apt install python3-argcomplete
# After shell restart work it
```

**On Ansible Machine** - under `root` user

### Create `directory` and `ansadmin`

```bash
useradd ansadmin
passwd ansadmin
mkdir /etc/ansible # if not available
id ansadmin
```

**On Ansible Machine** - under `root` user

### Add this user in `sudoers` file

```bash
cat /etc/sudoers
visudo
ansadmin ALL=(ALL) NOPASSWD: ALL
:wq! # saves anyway, Or
echo "ansadmin ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers
```

**On Ansible Machine** - under `root` user

### How to switch `Shell (sh)` to `Bash`

```bash
getent passwd ansadmin
ansadmin:x:1001:1001::/home/ansadmin:/bin/sh # if see,then
sudo chsh -s /bin/bash ansadmin # it change from `sh` to `bash`
getent passwd ansadmin
sudo mkdir -p /home/ansadmin
sudo chown ansadmin:ansadmin /home/ansadmin
sudo su - ansadmin
exit
```

## Docker install (It will be connected with docker as target server)

**On Ansible Machine** - under `root` user

### Docker Install

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

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo apt update
```

**On Ansible Machine** - under `root` user

### Add the user `ansadmin` to `docker` group

```bash
cat /etc/group # check group
usermod -aG docker ansadmin # Assign `ansadmin` user to `docker` group
id ansadmin # now `ansadmin` user member of `docker` & `ansadmin`
```

### Users are allowed to log in using a password over SSH

**On Ansible Machine** - under `root` user

```bash
vi /etc/ssh/sshd_config
PasswordAuthentication yes
systemctl restart ssh
```

**On Ansible Machine** - under `ansadmin` user

### Create `ssh-key`

```bash
sudo su - ansadmin
ssh-keygen
cd .ssh/
ls -la # should see `id_ed25519`, `id_ed25519.pub`
exit
```

## Docker server configuration

**On Docker Machine** - under `root` user

### Create `directory` and `ansadmin`

```bash
useradd ansadmin
passwd ansadmin
mkdir /etc/ansible # if not available
id ansadmin
```

### How to switch `Shell (sh)` to `Bash`

```bash
getent passwd ansadmin
ansadmin:x:1001:1001::/home/ansadmin:/bin/sh # if see,then
sudo chsh -s /bin/bash ansadmin # it change from `sh` to `bash`
getent passwd ansadmin
sudo mkdir -p /home/ansadmin
sudo chown ansadmin:ansadmin /home/ansadmin
sudo su - ansadmin
exit
```

### Login to docker server from `ansible` server

**On Ansible Machine** - under `ansadmin` user

```bash
sudo su - ansadmin
# Here, `192.168.1.112` is docker server IP
sudo ssh-copy-id ansadmin@192.168.1.112 # if something went wrong
ssh-copy-id -i ~/.ssh/id_ed25519.pub ansadmin@192.168.1.112
# Login to `docker` server from `ansible` server over ssh
sudo ssh ansadmin@192.168.1.112 # Server change from `ansadmin@ansible-server` to `ansadmin@docker-server`
exit # back to `ansible` server
```

### Now make sure ping & hosts configuration

**On Ansible Machine** - under `ansadmin` user

```bash
ping 192.168.1.112
sudo su - ansadmin
cd /etc/ansible/
sudo vi hosts
[docker_host]
192.168.1.112  ansible_python_interpreter=/usr/bin/python3 # docker server ip
localhost  ansible_python_interpreter=/usr/bin/python3 # Mean ansible server
ansible all -m ping
```

**If we not get localhost in ping** then

### Copy the SSH key & check again

**On Ansible Machine** - under `ansadmin` user

```bash
sudo ssh-copy-id localhost # if something went wrong
ssh-copy-id -i ~/.ssh/id_ed25519.pub localhost
ansible all -m ping
```

### Should see this result

```bash
localhost | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
192.168.1.112 | SUCCESS => {
    "changed": false,
    "ping": "pong"
}
```

### Connect to `docker` server to `ansible` server

- Add and Configure `SSH Server`
- Create item name `deploy-on-container-via-ansible`
- In `ansible` server `cd/opt` and `mkdir docker`
- Give ownership `sudo chown -R ansadmin:ansadmin /opt/docker`
- Check `ls -l /opt` and `cd /opt/docker`, `pwd`
- Remote directory `/opt/docker`
- `Apply`, `Save` and `Build` the Job.
