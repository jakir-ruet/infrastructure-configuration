## Java & Jenkins Install

### Java Install

```bash
sudo apt update
sudo apt upgrade -y
sudo apt install openjdk-21-jdk -y
java -version
```

### Add Jenkins key

```bash
curl -fsSL https://pkg.jenkins.io/debian/jenkins.io-2023.key | sudo tee \
  /usr/share/keyrings/jenkins-keyring.asc > /dev/null
```

### Add the Jenkins apt repository

```bash
echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian binary/ | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null
```

### Jenkins Install

```bash
sudo apt install jenkins -y
sudo systemctl start jenkins
sudo systemctl enable jenkins
sudo systemctl status jenkins
```

### Open Firewall (if UFW is active)

```bash
sudo ufw enable
sudo ufw allow 8080
sudo ufw reload
```

### Access Jenkins Web UI

```bash
http://localhost:8080
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
```
