# Dockerfile for Minecraft Java Server

FROM openjdk:17-jdk-alpine

ENV MINECRAFT_VERSION=1.21.1 \
    MINECRAFT_SERVER_DIR=/opt/minecraft \
    MEMORY_SIZE=2G

RUN mkdir -p $MINECRAFT_SERVER_DIR

WORKDIR $MINECRAFT_SERVER_DIR

# Download the Minecraft server jar
RUN wget -O server.jar https://piston-data.mojang.com/v1/objects/59353fb40c36d304f2035d51e7d6e6baa98dc05c/server.jar

# Accept the EULA by adding a configuration file
RUN echo "eula=true" > eula.txt

# Expose Minecraft server port
EXPOSE 25565

# Start the Minecraft server
CMD ["sh", "-c", "java -Xmx${MEMORY_SIZE} -Xms${MEMORY_SIZE} -jar server.jar nogui"]
