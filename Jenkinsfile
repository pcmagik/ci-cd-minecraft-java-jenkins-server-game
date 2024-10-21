pipeline {
    agent any
    environment {
        REPO = 'https://github.com/pcmagik/ci-cd-minecraft-server.git'
        IMAGE_NAME = 'minecraft-server:latest'
        NETWORK_NAME = 'jenkins'
        BACKUP_DIR = '/var/jenkins_home/minecraft-backups'
        PROD_SERVER_NAME = 'minecraft-server-prod'
        TEST_SERVER_NAME = 'minecraft-server-test'
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
                    timeout(time: 2, unit: 'MINUTES') {
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
                    // Sprawdzanie logów serwera Minecraft
                    sh "docker logs ${TEST_SERVER_NAME}"
                }
            }
        }
        stage('Automated Tests') {
            steps {
                script {
                    // Pobieranie IP kontenera
                    def containerIp = sh(script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${TEST_SERVER_NAME}", returnStdout: true).trim()
                    // Sprawdzanie dostępności portu 25565 przy użyciu nc
                    if (sh(script: "nc -zv ${containerIp} 25565", returnStatus: true) != 0) {
                        error("Port 25565 na kontenerze ${containerIp} nie jest dostępny. Test nie przeszedł.")
                    }
                }
            }
        }
        stage('Backup Existing Production') {
            steps {
                script {
                    sh "mkdir -p ${BACKUP_DIR}"
                    if (sh(script: "docker ps -q -f name=${PROD_SERVER_NAME}", returnStatus: true) == 0) {
                        if (sh(script: "docker exec ${PROD_SERVER_NAME} ls /opt/minecraft/world", returnStatus: true) == 0) {
                            sh "docker cp ${PROD_SERVER_NAME}:/opt/minecraft/world ${BACKUP_DIR}/world_\$(date +%Y%m%d_%H%M%S) || true"
                        } else {
                            echo "Nie znaleziono danych świata w kontenerze produkcyjnym, pomijanie kopii zapasowej."
                        }
                    } else {
                        echo "Nie znaleziono kontenera produkcyjnego, pomijanie kopii zapasowej."
                    }
                }
            }
        }
        stage('Deploy to Production') {
            steps {
                script {
                    // Zatrzymanie i usunięcie testowego serwera przed wdrożeniem na produkcję
                    sh "docker stop ${TEST_SERVER_NAME} || true"
                    sh "docker rm ${TEST_SERVER_NAME} || true"
                    
                    // Sprawdzenie, czy serwer testowy działa poprawnie przed wdrożeniem na produkcję
                    def containerIp = sh(script: "docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${TEST_SERVER_NAME}", returnStdout: true).trim()
                    if (sh(script: "nc -zv ${containerIp} 25565", returnStatus: true) == 0) {
                        sh "docker stop ${PROD_SERVER_NAME} || true"
                        sh "docker rm ${PROD_SERVER_NAME} || true"
                        docker.image(IMAGE_NAME).run("-d --network ${NETWORK_NAME} -p 25565:25565 --name ${PROD_SERVER_NAME}")
                    } else {
                        error("Serwer testowy nie jest dostępny. Przerwanie wdrażania na produkcję.")
                    }
                }
            }
        }
        stage('Monitor Production') {
            steps {
                script {
                    // Prosta monitorowanie, że serwer działa
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
                sh "docker stop ${PROD_SERVER_NAME} || true"
                sh "docker rm ${PROD_SERVER_NAME} || true"
                sh "docker rmi ${IMAGE_NAME} --force || true"
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
