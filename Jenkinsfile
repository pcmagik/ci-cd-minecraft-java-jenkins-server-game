pipeline {
    agent {
        docker {
            image 'docker:20.10.12' 
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        IMAGE_NAME = 'minecraft_server'
        CONTAINER_NAME = 'minecraft'
        DOCKERFILE_DIR = './docker/minecraft'
    }

    stages {
        stage('Clone repository') {
            steps {
                script {
                    git branch: 'main', url: 'https://github.com/YOUR-REPO.git'
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                script {
                    sh """
                    docker build -t ${IMAGE_NAME}:latest ${DOCKERFILE_DIR}
                    """
                }
            }
        }

        stage('Run Docker Container') {
            steps {
                script {
                    // Stop and remove existing container if it exists
                    sh """
                    docker stop ${CONTAINER_NAME} || true
                    docker rm ${CONTAINER_NAME} || true
                    """
                    
                    // Run the new Minecraft server container
                    sh """
                    docker run -d -p 25565:25565 --name ${CONTAINER_NAME} ${IMAGE_NAME}:latest
                    """
                }
            }
        }
    }

    post {
        success {
            echo 'Minecraft server successfully deployed.'
        }
        failure {
            echo 'Pipeline failed. Check console output for details.'
        }
    }
}
