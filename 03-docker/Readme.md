## Docker Server Install and configuration

### Install using the apt repository

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

### Install

```bash
sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
```

### Install Tomcat image and container (Official image recommended)

```bash
https://hub.docker.com/_/tomcat
docker pull tomcat:10.0 # pulling 10.0 tomcat image
docker images
docker run -d --name tomcat-container -p 8080:8080 tomcat:10.0
docker ps
```

### Check from browser

```bash
http://localhost:8080/webapps
```

## Making connectivity with `Jenkins` server

- Install `Publish over ssh` o Jenkins server

### Create `dockeradmin` user on docker server

```bash
useradd dockeradmin
passwd dockeradmin
cat /etc/group # check docker group
```

### making a member `dockeradmin` of `docker` group

```bash
id dockeradmin # uid=1001(dockeradmin) gid=1001(dockeradmin) groups=1001(dockeradmin)
usermod -aG docker dockeradmin # uid=1001(dockeradmin) gid=1001(dockeradmin) groups=1001(dockeradmin),988(docker)
```

### Now go back `Jenkins` and setup `username` a& `password` through Jenkins
- Go `System`
- `Publish over SSH`
- Add `SSH Servers`

```bash
docker-host # Name
192.168.1.111 # Hostname
dockeradmin
# click advance &
# check `Use password authentication, or use a different key`
# put the password of dockeradmin
# click test
```

### Change `PasswordAuthentication yes`, default `PasswordAuthentication yes` we need `yes`

```bash
vi /etc/ssh/sshd_config
PasswordAuthentication yes
systemctl restart sshd
# If Success then Apply & Save
```

### Create new `Item` name `deploy-on-docker` & copy from 'deploy-on-tomcat-server' hit `Ok`

- Click on `Add post-build action`
- Go `Send build artifacts over SSH` and configure properly
- `webapps.war` path
- `cd /var/lib/jenkins/workspace/deploy-on-tomcat-server/target`
- `pwd`
- `target/*.war`
- If you have no `exec command`
- The `Apply` and `Save`

### Login as `dockeradmin`in docker server

```bash
sudo mkdir -p /home/dockeradmin
# Build the job from `Jenkins` server
cd /home/dockeradmin
sudo su - dockeradmin
whoami
ls -ltr
cd target
webapps.war # available
```
