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
                    sh 'docker stop minecraft-server-test || true'
                    sh 'docker rm minecraft-server-test || true'
                    docker.image("${env.IMAGE_NAME}").run("-d --network ${env.NETWORK_NAME} -p 25565:25565 --name minecraft-server-test -e MEMORY_SIZE=2G")
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
                    if (sh(script: "nc -zv ${containerIp} 25565", returnStatus: true) != 0) {
                        error("Port 25565 na kontenerze ${containerIp} nie jest dostępny. Test nie przeszedł.")
                    }
                }
            }
        }
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    // Sprawdzenie, czy serwer testowy działa poprawnie przed wdrożeniem na produkcję
                    def containerIp = sh(script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' minecraft-server-test", returnStdout: true).trim()
                    if (sh(script: "nc -zv ${containerIp} 25565", returnStatus: true) == 0) {
                        sh 'docker stop minecraft-server-prod || true'
                        sh 'docker rm minecraft-server-prod || true'
                        docker.image("${env.IMAGE_NAME}").run("-d --network ${env.NETWORK_NAME} -p 25565:25565 --name minecraft-server-prod")
                    } else {
                        error("Serwer testowy nie jest dostępny. Przerwanie wdrażania na produkcję.")
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                sh 'docker stop minecraft-server-test || true'
                sh 'docker rm minecraft-server-test || true'
                sh "docker rmi ${env.IMAGE_NAME} || true"
            }
        }
    }
}
