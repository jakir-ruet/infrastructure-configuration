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

### Create `dockeradmin` user

```bash
useradd dockeradmin
passwd dockeradmin
cat /etc/group
id dockeradmin
```

### Assign `dockeradmin`user to `docker` group in docker server

```bash
usermod -aG docker dockeradmin
id dockeradmin
```

### Create `dockeradmin` directory and assign to `dockeradmin` user

```bash
sudo mkdir -p /home/dockeradmin
sudo chown dockeradmin:dockeradmin /home/dockeradmin
```

### Go back to `Jenkins` server for connect each other

- Add `SSH Server` using `Publish over SSH`
- Name `docker-host`
- Hostname `Docker Machine IP`
- Username `Docker User Name`
- Remote Directory `Where do you put`
- Go Advance give `Docker server Password`
- Test check, Save & Apply.

### Allow `PasswordAuthentication yes` in `/etc/ssh/sshd_config`

```bash
PasswordAuthentication yes
sudo systemctl enable ssh
sudo systemctl restart ssh
sudo systemctl status ssh
ssh dockeradmin@docker-server-IP
```

### How to switch `$ to dockeradmin@docker-server`

```bash
getent passwd dockeradmin
dockeradmin:x:1001:1001::/home/dockeradmin:/bin/bash  # should see, then okay
dockeradmin:x:1001:1001::/home/dockeradmin:/bin/sh # not should see, then run
sudo usermod -s /bin/bash dockeradmin
ssh dockeradmin@docker-server-IP # or
sudo su - dockeradmin
```

- User should change `root` to `dockeradmin`

### In Jenkins portal

- `Source File` must `target/*.war`
- `Remove Prefix` must `target/`
- `Remote Directory` must `/home/dockeradmin`

### Run in `/home/dockeradmin`

```bash
docker stop tomcat9 || true && \
docker rm tomcat9 || true && \
docker run -d --name tomcat9 -p 8080:8080 \
-v /home/dockeradmin/webapp.war:/usr/local/tomcat/webapps/webapp.war \
tomcat:9
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
cat /etc/group # check docker group
useradd dockeradmin
passwd dockeradmin
id dockeradmin
sudo mkdir -p /home/dockeradmin
sudo chown dockeradmin:dockeradmin /home/dockeradmin
```

### How to switch `$ to dockeradmin@docker-server`

```bash
getent passwd dockeradmin
dockeradmin:x:1001:1001::/home/dockeradmin:/bin/bash  # should see
dockeradmin:x:1001:1001::/home/dockeradmin:/bin/sh # not should see, then run
sudo usermod -s /bin/bash dockeradmin
sudo su - dockeradmin
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
docker-server # Name
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
systemctl restart ssh
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
