sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install openjdk-8-jre -y
sudo apt-get install unzip -y
cd /opt
sudo wget https://sonarsource.bintray.com/Distribution/sonarqube/sonarqube-6.7.zip
sudo unzip sonarqube-6.7.zip
sudo mv sonarqube-6.7 sonar
sudo adduser sonar
sudo chown sonar:sonar -R sonar
sudo vi /opt/sonar/conf/sonar.properties

---
sonar.jdbc.username=sonar
sonar.jdbc.password=
sonar.jdbc.url=jdbc:mysql://sonarqube-db-host:3306/sonar?useUnicode=true&characterEncoding=utf8&rewriteBatchedStatements=true&useConfigs=maxPerformance&useSSL=false
---

sudo vi /etc/systemd/system/sonar.service

---
[Unit]
Description=SonarQube service
After=syslog.target network.target

[Service]
Type=forking

ExecStart=/opt/sonar/bin/linux-x86-64/sonar.sh start
ExecStop=/opt/sonar/bin/linux-x86-64/sonar.sh stop

User=sonar
Group=sonar
Restart=always

[Install]
WantedBy=multi-user.target
---

sudo systemctl enable sonar
sudo systemctl start sonar
