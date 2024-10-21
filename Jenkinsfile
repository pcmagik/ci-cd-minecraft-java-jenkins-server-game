pipeline {
    agent any
    environment {
        REPO = 'https://github.com/pcmagik/ci-cd-minecraft-server.git'
        IMAGE_NAME = 'minecraft-server:latest'
        NETWORK_NAME = 'jenkins'
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: "${env.REPO}", credentialsId: 'global_github_ssh'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build("${env.IMAGE_NAME}")
                }
            }
        }
        stage('Test Docker Image') {
            steps {
                script {
                    docker.image("${env.IMAGE_NAME}").inside("--network ${env.NETWORK_NAME}") {
                        sh 'java -version'
                    }
                }
            }
        }
        stage('Deploy to Test Environment') {
            steps {
                script {
                    docker.image("${env.IMAGE_NAME}").run("-d --network ${env.NETWORK_NAME} -p 25565:25565 --name minecraft-server-test")
                    // Daj czas na pełne uruchomienie serwera
                    sh 'sleep 10'
                }
            }
        }
        stage('Check Server Logs') {
            steps {
                script {
                    // Sprawdzanie logów serwera Minecraft
                    sh 'docker logs minecraft-server-test'
                }
            }
        }
        stage('Automated Tests') {
            steps {
                script {
                    // Pobieranie IP kontenera
                    def containerIp = sh(script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minecraft-server-test", returnStdout: true).trim()
                    // Sprawdzanie dostępności portu 25565 przy użyciu nc
                    sh "nc -zv ${containerIp} 25565 || exit 1"
                }
            }
        }
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh 'docker stop minecraft-server-test || true'
                    sh 'docker rm minecraft-server-test || true'
                    docker.image("${env.IMAGE_NAME}").run("-d --network ${env.NETWORK_NAME} -p 25565:25565 --name minecraft-server-prod")
                }
            }
        }
    }
    post {
        always {
            script {
                sh 'docker stop minecraft-server-test || true'
                sh 'docker rm minecraft-server-test || true'
            }
        }
    }
}
