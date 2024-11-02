# Dockerfile for Minecraft Java Server

# Start with the official OpenJDK 21 image as a base
FROM openjdk:21-jdk-slim

# Set build argument for Minecraft server JAR URL
ARG SERVER_JAR_URL

# Set environment variables
ENV MINECRAFT_SERVER_DIR=/opt/minecraft \
    MEMORY_SIZE=2G

# Install wget using apt-get
RUN apt-get update && apt-get install wget -y

# Create the Minecraft directory
RUN mkdir -p $MINECRAFT_SERVER_DIR

WORKDIR $MINECRAFT_SERVER_DIR

# Copy server.properties from the local machine to the container
COPY server.properties $MINECRAFT_SERVER_DIR/

# Download the Minecraft server jar using the URL provided in build argument
RUN wget -O server.jar ${SERVER_JAR_URL}

# Accept the EULA by adding a configuration file
RUN echo "eula=true" > eula.txt

# Expose Minecraft server port
EXPOSE 25565

# Start the Minecraft server
CMD ["sh", "-c", "java -Xmx${MEMORY_SIZE} -Xms${MEMORY_SIZE} -jar server.jar nogui"]
