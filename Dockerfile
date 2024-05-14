FROM openjdk:8-jdk-alpine

VOLUME /tmp
EXPOSE 25565

# Użyj najnowszego URL do pobrania pliku server.jar
ADD https://piston-data.mojang.com/v1/objects/145ff0858209bcfc164859ba735d4199aafa1eea/server.jar /minecraft-server/server.jar

# Dodaj plik eula.txt z akceptacją EULA
RUN echo "eula=true" > /minecraft-server/eula.txt

WORKDIR /minecraft-server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]
