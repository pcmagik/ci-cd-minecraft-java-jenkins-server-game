pipeline {
    agent {
        docker {
            image 'docker:20.10.12'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    stages {
        stage('Build Docker Image') {
            steps {
                sh 'docker --version'
                sh 'docker build -t minecraft_server:latest ./docker/minecraft'
            }
        }
    }
}
