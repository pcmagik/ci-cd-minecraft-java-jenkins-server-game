FROM openjdk:8-jdk-alpine

VOLUME /tmp
EXPOSE 25565

# Użyj najnowszego URL do pobrania pliku server.jar
ADD https://launcher.mojang.com/v1/objects/f1a0073671057f01aa843443fef34330281333ce/server.jar /minecraft-server/server.jar

# Dodaj plik eula.txt z akceptacją EULA
RUN echo "eula=true" > /minecraft-server/eula.txt

WORKDIR /minecraft-server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]
