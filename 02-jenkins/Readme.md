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
sudo apt update
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

## [Maven](https://maven.apache.org/download.cgi) Install (JDK 21 is Required)

```bash
wget https://dlcdn.apache.org/maven/maven-3/3.9.10/binaries/apache-maven-3.9.10-bin.tar.gz
tar -zxvf apache-maven-3.9.10-bin.tar.gz
mv apache-maven-3.9.10 maven
vi ~/.bashrc
# Put below two lines here, for maven
export MAVEN_HOME=/opt/maven
export PATH=$PATH:$HOME/bin:$MAVEN_HOME/bin
source ~/.bashrc
echo $MAVEN_HOME
echo $PATH
mvn -v
```
