# Dockerfile for Minecraft Java Server

# Start with the official OpenJDK 21 image as a base
FROM openjdk:21-jdk-slim

# Set environment variables
ENV MINECRAFT_SERVER_DIR=/opt/minecraft \
    MEMORY_SIZE=2G

# Define build argument for server URL
ARG SERVER_JAR_URL

# Install wget using apt-get in a single RUN command to reduce image layers
RUN apt-get update && apt-get install -y wget && \
    mkdir -p $MINECRAFT_SERVER_DIR && \
    apt-get clean

# Set working directory
WORKDIR $MINECRAFT_SERVER_DIR

# Copy server.properties from the local machine to the container
COPY server.properties $MINECRAFT_SERVER_DIR/

# Download the Minecraft server jar using the argument provided
RUN wget -O server.jar ${SERVER_JAR_URL}

# Accept the EULA by adding a configuration file
RUN echo "eula=true" > eula.txt

# Expose Minecraft server port
EXPOSE 25565

# Start the Minecraft server
CMD ["sh", "-c", "java -Xmx${MEMORY_SIZE} -Xms${MEMORY_SIZE} -jar server.jar nogui"]
