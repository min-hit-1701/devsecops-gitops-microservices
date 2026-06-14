FROM jenkins/jenkins:lts-jdk17
USER root
RUN apt-get update && apt-get install -y wget unzip python3 && rm -rf /var/lib/apt/lists/*
RUN wget -q https://github.com/aquasecurity/trivy/releases/download/v0.58.0/trivy_0.58.0_Linux-64bit.deb -O /tmp/trivy.deb && dpkg -i /tmp/trivy.deb && rm /tmp/trivy.deb
RUN wget -q https://github.com/jeremylong/DependencyCheck/releases/download/v12.1.1/dependency-check-12.1.1-release.zip -O /tmp/dc.zip && unzip -q /tmp/dc.zip -d /opt/ && rm /tmp/dc.zip && ln -sf /opt/dependency-check /opt/dependency-check-offload
USER jenkins
