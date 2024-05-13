FROM openjdk:8-jdk-alpine
VOLUME /tmp
EXPOSE 25565
ADD https://launcher.mojang.com/v1/objects/0b790debf5583f8f6e1a3b7f5c7b060d7f02b009/server.jar /minecraft-server/server.jar
WORKDIR /minecraft-server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]
