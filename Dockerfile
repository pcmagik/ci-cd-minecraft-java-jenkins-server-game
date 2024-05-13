FROM openjdk:8-jdk-alpine
VOLUME /tmp
EXPOSE 25565
ADD https://launcher.mojang.com/v1/objects/f1a0073671057f01aa843443fef34330281333ce/server.jar /minecraft-server/server.jar
WORKDIR /minecraft-server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]