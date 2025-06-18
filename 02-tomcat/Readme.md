## Tomcat 9 Install

### Install Java (if not installed)

```bash
sudo apt update
sudo apt install openjdk-21-jdk -y
java -version
```

### [Download and Install Tomcat 9](https://tomcat.apache.org/download-90.cgi)

```bash
cd /opt
wget https://dlcdn.apache.org/tomcat/tomcat-9/v9.0.106/bin/apache-tomcat-9.0.106.tar.gz
tar -zxvf apache-tomcat-9.0.106.tar.gz
mv apache-tomcat-9.0.106 tomcat
```

### Set permission

```bash
cd tomcat/bin/
chmod +x startup.sh
chmod +x shutdown.sh
```

### Making symbolic link for start and stop

```bash
sudo ln -s /opt/tomcat/bin/startup.sh /usr/local/bin/tomcatup
tomcatup # start the server
sudo ln -s /opt/tomcat/bin/shutdown.sh /usr/local/bin/tomcatdown
tomcatdown # stop the server
```

### Open Firewall (if UFW is active)

```bash
sudo ufw enable
sudo ufw allow 8080
sudo ufw reload
```

### Access Tomcat Web Interface

```bash
http://localhost:8080
cd /opt/tomcat/conf
sudo cat server.xml
sudo vi server.xml
```

### Port change (If needed)

```bash
cd /opt/tomcat/conf
sudo cat server.xml
sudo vi server.xml
```

### Active for asking User ID Password

```bash
find / -name context.xml
# See
/opt/tomcat/webapps/host-manager/META-INF/context.xml
/opt/tomcat/webapps/docs/META-INF/context.xml
/opt/tomcat/webapps/examples/META-INF/context.xml
/opt/tomcat/webapps/manager/META-INF/context.xml
/opt/tomcat/conf/context.xml
```

- Here comment `/opt/tomcat/webapps/host-manager/META-INF/context.xml`
<!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->
- Here comment `/opt/tomcat/webapps/manager/META-INF/context.xml`
<!-- <Valve className="org.apache.catalina.valves.RemoteAddrValve"
         allow="127\.\d+\.\d+\.\d+|::1|0:0:0:0:0:0:0:1" /> -->

### Update users information

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

### Restart tomcat services

```bash
tomcatdown
tomcatup
```

### Login

```bash
http://localhost:8080/
```
