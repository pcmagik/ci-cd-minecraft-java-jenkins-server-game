pipeline {
    agent {
        docker {
            image 'docker:20.10.12'
            args '-v /var/run/docker.sock:/var/run/docker.sock --privileged'
        }
    }

    stages {
        stage('Clone repository') {
            steps {
                git branch: 'main', url: 'https://github.com/pcmagik/ci-cd-minecraft-jenkins-server-game.git'
            }
        }

        stage('Build Docker Image') {
            steps {
                sh 'docker build -t minecraft_server:latest ./docker/minecraft'
            }
        }
    }
}
