pipeline {
    agent {
        docker {
            image 'jenkins/jenkins:lts'
            args '-v /var/run/docker.sock:/var/run/docker.sock'
        }
    }

    environment {
        PATH = "/usr/local/bin:/usr/bin:${env.PATH}"
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
