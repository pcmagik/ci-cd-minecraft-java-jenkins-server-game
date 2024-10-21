pipeline {
    agent any
    environment {
        REPO = 'https://github.com/pcmagik/ci-cd-minecraft-server.git'
        IMAGE_NAME = 'minecraft-server:latest'
        NETWORK_NAME = 'jenkins'
        BACKUP_DIR = '/var/jenkins_home/minecraft-backups'
        PROD_SERVER_NAME = 'minecraft-server-prod'
        TEST_SERVER_NAME = 'minecraft-server-test'
        DATA_DIR = '/var/jenkins_home/minecraft-data'
    }
    stages {
        stage('Clone Repository') {
            steps {
                git branch: 'main', url: "${REPO}", credentialsId: 'global_github_ssh'
            }
        }
        stage('Build Docker Image') {
            steps {
                script {
                    docker.build(IMAGE_NAME)
                }
            }
        }
        stage('Test Docker Image') {
            steps {
                script {
                    docker.image(IMAGE_NAME).inside("--network ${NETWORK_NAME}") {
                        sh 'java -version'
                    }
                }
            }
        }
        stage('Deploy to Test Environment') {
            steps {
                script {
                    sh "docker stop ${TEST_SERVER_NAME} || true"
                    sh "docker rm ${TEST_SERVER_NAME} || true"
                    docker.image(IMAGE_NAME).run("-d --network ${NETWORK_NAME} -p 25565:25565 --name ${TEST_SERVER_NAME} -e MEMORY_SIZE=2G")
                    
                    // Zamiast sleep czekamy na informację, że serwer jest gotowy
                    timeout(time: 1, unit: 'MINUTES') {
                        waitUntil {
                            def logOutput = sh(script: "docker logs ${TEST_SERVER_NAME}", returnStdout: true)
                            return logOutput.contains('Done')
                        }
                    }
                }
            }
        }
        stage('Check Server Logs') {
            steps {
                script {
                    sh "docker logs ${TEST_SERVER_NAME}"
                }
            }
        }
        stage('Automated Tests') {
            steps {
                script {
                    def containerIp = sh(script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${TEST_SERVER_NAME}", returnStdout: true).trim()
                    if (sh(script: "nc -zv ${containerIp} 25565", returnStatus: true) != 0) {
                        error("Port 25565 na kontenerze ${containerIp} nie jest dostępny. Test nie przeszedł.")
                    }
                }
            }
        }
        stage('Backup Existing Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    sh "mkdir -p ${BACKUP_DIR}"
                    sh "docker cp ${PROD_SERVER_NAME}:/opt/minecraft/world ${BACKUP_DIR}/world_\$(date +%Y%m%d_%H%M%S) || true"
                }
            }
        }
        stage('Deploy to Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def containerIp = sh(script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${TEST_SERVER_NAME}", returnStdout: true).trim()
                    if (sh(script: "nc -zv ${containerIp} 25565", returnStatus: true) == 0) {
                        sh "docker stop ${PROD_SERVER_NAME} || true"
                        sh "docker rm ${PROD_SERVER_NAME} || true"
                        docker.image(IMAGE_NAME).run("-d --network ${NETWORK_NAME} -p 25565:25565 --name ${PROD_SERVER_NAME} -v ${DATA_DIR}:/opt/minecraft/world")
                    } else {
                        error("Serwer testowy nie jest dostępny. Przerwanie wdrażania na produkcję.")
                    }
                }
            }
        }
        stage('Monitor Production') {
            when {
                branch 'main'
            }
            steps {
                script {
                    def prodIp = sh(script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${PROD_SERVER_NAME}", returnStdout: true).trim()
                    if (sh(script: "nc -zv ${prodIp} 25565", returnStatus: true) != 0) {
                        error("Serwer produkcyjny nie jest dostępny. Konieczne jest działanie.")
                    } else {
                        echo "Serwer produkcyjny działa prawidłowo."
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                sh "docker stop ${TEST_SERVER_NAME} || true"
                sh "docker rm ${TEST_SERVER_NAME} || true"
                sh "docker rmi ${IMAGE_NAME} || true"
            }
        }
        failure {
            script {
                // Wysłanie notyfikacji w przypadku nieudanej operacji
                echo "Pipeline zakończony niepowodzeniem. Wysyłanie powiadomienia..."
                // Możesz tutaj dodać np. integrację z Slackiem
            }
        }
    }
}

