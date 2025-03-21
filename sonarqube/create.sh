# File used only to save the script, it must be on github action run
# is not possible to run it alone
cat <<-EOF > "Dockerfile"
FROM sonarqube:9.9.7-community

USER root
RUN apt-get update && \\
    apt-get install -y unzip curl && \\
    curl -sSLo /tmp/sonar-scanner.zip https://binaries.sonarsource.com/Distribution/sonar-scanner-cli/sonar-scanner-cli-4.6.2.2472-linux.zip && \\
    unzip /tmp/sonar-scanner.zip -d /opt && \\
    ln -s /opt/sonar-scanner-4.6.2.2472-linux /opt/sonar-scanner && \\
    rm /tmp/sonar-scanner.zip

ENV SONAR_SCANNER_HOME=/opt/sonar-scanner
ENV PATH=\$PATH:\$SONAR_SCANNER_HOME/bin


# cloud
EXPOSE 9000 
# cli
EXPOSE 9001 

RUN echo "echo 'wait...'; until echo \"\\\$sonarStatus\" | grep -q '\"status\":\"UP\"'; do \\
    sonarStatus=\\\$(curl -s http://localhost:9000/api/system/status); \\
    echo \"\\\$sonarStatus\" || \"...\"; \\
    sleep 1; \\
  done" > wait-health.sh
RUN chmod +x wait-health.sh

RUN echo "echo 'scanning...'; sonar-scanner" > scan.sh
RUN chmod +x scan.sh

USER sonarqube

EOF

docker build . -t custom-sonarqube:latest --progress=plain
# rm -rf Dockerfile

docker run -d --name run-sonarqube \
  -v ./:/app \
  -p 9090:9000 \
  -p 9091:9001 \
  -e "SONAR_JDBC_URL=*********" \
  -e "SONAR_JDBC_USERNAME=****" \
  -e "SONAR_JDBC_PASSWORD=****" \
  custom-sonarqube:latest

docker exec run-sonarqube bash wait-health.sh

docker exec run-sonarqube bash scan.sh
