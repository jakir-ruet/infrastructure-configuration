## Tomcat install and configuration

### Install Java 21

```bash
sudo apt update
sudo apt install openjdk-21-jdk -y
java -version
sudo apt update
```

### [Download and Install Tomcat 10](https://tomcat.apache.org/download-10.cgi)

```bash
cd /opt
sudo wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.42/bin/apache-tomcat-10.1.42.tar.gz
sudo tar -xzf apache-tomcat-10.1.42.tar.gz
sudo mv apache-tomcat-10.1.42 tomcat
sudo rm apache-tomcat-10.1.42.tar.gz
```

### Create Tomcat User (Recommended for Security)

```bash
sudo useradd -m -U -d /opt/tomcat -s /bin/false tomcat
sudo passwd tomcat
sudo chown -R tomcat: /opt/tomcat
```

### Set Environment Variables > (Recommended)

```bash
sudo vi /etc/profile.d/tomcat.sh
export JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64
export CATALINA_HOME=/opt/tomcat
export PATH=$PATH:$JAVA_HOME/bin:$CATALINA_HOME/bin
```

### Make executable

```bash
sudo chmod +x /etc/profile.d/tomcat.sh
source /etc/profile.d/tomcat.sh
```

```bash
echo $JAVA_HOME
echo $CATALINA_HOME
```

#### Version check

```bash
cd /opt/tomcat/bin
./version.sh
```

### Setup systemd Service (Professional Approach)

```bash
sudo vi /etc/systemd/system/tomcat.service
```

#### Paste

```bash
[Unit]
Description=Apache Tomcat 9 Web Application Server
After=network.target

[Service]
Type=simple
User=tomcat
Group=tomcat

Environment="JAVA_HOME=/usr/lib/jvm/java-21-openjdk-arm64"
Environment="CATALINA_HOME=/opt/tomcat"
Environment="CATALINA_BASE=/opt/tomcat"
Environment="CATALINA_PID=/opt/tomcat/temp/tomcat.pid"

ExecStart=/opt/tomcat/bin/catalina.sh run
ExecStop=/opt/tomcat/bin/catalina.sh stop
SuccessExitStatus=143
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

#### Enable and start

```bash
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat
sudo systemctl status tomcat
```

### Configure Firewall (If UFW is Enabled)

```bash
sudo ufw allow 8080/tcp
sudo ufw reload
```

### Deploy method `one` - using `index.jsp`

```bash
sudo nano /opt/tomcat/webapps/ROOT/index.jsp # for root directory
sudo nano /opt/tomcat/webapps/webapp/index.jsp # for webapp directory
```

```html
<%@ page language="java" %>
<html>
  <head><title>Tomcat 9 | Welcome to from Tomcat</title></head>
  <body>
    <h1>Hello, Welcome to from Tomcat 9!</h1>
  </body>
</html>
```

```bash
sudo systemctl restart tomcat
```

### Access Tomcat

```bash
http://localhost:8080 # for root
http://localhost:8080/webapp # for webapp
```

### Deploy method `two` - using `webapp.war`

- build your Java web app
- package it as `myapp.war`
- copy it to `/opt/tomcat/webapps/`
- Tomcat will auto-deploy it

### Access Tomcat

```bash
http://localhost:8080/myapp
```

### Configure Tomcat Web Applications

#### Enable Remote Access to `manager` & `host-manager`

```bash
find / -name context.xml
sudo vi /opt/tomcat/webapps/manager/META-INF/context.xml
sudo vi /opt/tomcat/webapps/host-manager/META-INF/context.xml
```

#### Comment Out/Remove from above two

```bash
<Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" />
```

### Add Admin Users

```bash
sudo vi /opt/tomcat/conf/tomcat-users.xml
<role rolename="manager-gui"/>
<role rolename="manager-script"/>
<role rolename="manager-jmx"/>
<role rolename="manager-status"/>
<user username="admin" password="newAdminPassword" roles="manager-gui,manager-script,manager-jmx,manager-status"/>
<user username="deployer" password="newDeployerPassword" roles="manager-script"/>
<user username="tomcat" password="newTomcatPassword" roles="manager-gui"/>
```

```bash
sudo systemctl restart tomcat
```

### Change Default Port (Optional)

```bash
sudo vi /opt/tomcat/conf/server.xml
<Connector port="8085" protocol="HTTP/1.1"
sudo systemctl restart tomcat
```

## Tomcat deployment on container via `Jenkins`

### Install plugin `deploy to container`

- `Deploy to container`
- `Select Git and give URL & Credential if needed`
- `Post-build Actions - Deploy war/ear to a container`
  - `WAR/EAR file`
  - `Context path`
- `Jenkins Credentials Provider: Jenkins`

### Give the access permission to only specific IP in tomcat

```bash
<Valve className="org.apache.catalina.valves.RemoteAddrValve" allow="192\.168\.1\.109" />
```

### Configure other associates settings and build the application

- Triggers
- Environment
- Pre Steps & others.

### Access from browser

```bash
http://localhost:8080/webapps
```

### We will get

![Login Screen](/img/war-mvn-login.png)

Using the user ID and Password you will be able to use the application.
