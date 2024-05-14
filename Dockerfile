FROM openjdk:8-jdk-alpine

VOLUME /tmp
EXPOSE 25565

# Użyj najnowszego URL do pobrania pliku server.jar
ADD https://launcher.mojang.com/v1/objects/8e7c75ecb784ab69df7a1b9a1e8893e70a042e7a/server.jar /minecraft-server/server.jar

# Dodaj plik eula.txt z akceptacją EULA
RUN echo "eula=true" > /minecraft-server/eula.txt

WORKDIR /minecraft-server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]
