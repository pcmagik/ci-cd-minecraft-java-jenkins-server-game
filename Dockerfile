FROM openjdk:21-jdk

VOLUME /tmp
EXPOSE 25565

# Użyj najnowszego URL do pobrania pliku server.jar
ADD https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar /minecraft-server/server.jar

# Dodaj plik eula.txt z akceptacją EULA
RUN echo "eula=true" > /minecraft-server/eula.txt

WORKDIR /minecraft-server
CMD ["java", "-Xmx1024M", "-Xms1024M", "-jar", "server.jar", "nogui"]
