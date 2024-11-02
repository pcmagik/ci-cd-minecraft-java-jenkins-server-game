pipeline {
    agent any
    environment {
        REPO = 'https://github.com/pcmagik/ci-cd-minecraft-jenkins-server-game.git'
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
                // Wyświetl zawartość katalogu po klonowaniu, aby sprawdzić, czy wszystko jest dostępne
                sh 'ls -R'
            }
        }

        stage('Check Workspace') {
            steps {
                // Sprawdzenie, czy plik `get_latest_version.py` jest dostępny
                sh 'ls -la'
                sh 'ls -la scripts'
            }
        }

        stage('Create Python Virtual Environment') {
            steps {
                sh 'python3 -m venv venv'
                sh './venv/bin/pip install requests'
            }
        }

        stage('Update Minecraft Server Version') {
            steps {
                sh './venv/bin/python scripts/get_latest_version.py > latest_url.txt'
                
                script {
                    def latestUrl = readFile('latest_url.txt').trim()
                    env.SERVER_JAR_URL = latestUrl
                }
            }
        }

        stage('Build Docker Image') {
            steps {
                // Zbuduj obraz Docker, przekazując zmienną jako argument budowy
                sh 'docker build --build-arg SERVER_JAR_URL=${SERVER_JAR_URL} -t minecraft-server:latest .'
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
                    docker.image(IMAGE_NAME).run("-d --network ${NETWORK_NAME} -p 25567:25565 --name ${TEST_SERVER_NAME} -e MEMORY_SIZE=2G")
                    
                    // Czekamy na informację, że serwer jest gotowy
                    timeout(time: 5, unit: 'MINUTES') {
                        waitUntil {
                            def logOutput = sh(script: "docker logs ${TEST_SERVER_NAME}", returnStdout: true)
                            echo logOutput // Logowanie w celu sprawdzenia statusu
                            return logOutput.contains('Done')
                        }
                    }
                }
            }
        }

        stage('Automated Tests') {
            steps {
                script {
                    // Pobierz publiczny adres IP maszyny
                    def testIP = sh(script: "curl -s ifconfig.me", returnStdout: true).trim()

                    // Sprawdzanie dostępności portu z zewnętrznej perspektywy
                    retry(5) {
                        if (sh(script: "nc -zv ${testIP} 25567", returnStatus: true) != 0) {
                            echo "Port 25567 na adresie ${testIP} nie jest dostępny. Próba ponowna."
                            sleep(time: 10, unit: 'SECONDS')
                            error("Port 25567 nie jest dostępny, ponawiam test.")
                        }
                    }
                    // Usunięcie kontenera testowego po zakończeniu testów
                    sh "docker stop ${TEST_SERVER_NAME} || true"
                    sh "docker rm ${TEST_SERVER_NAME} || true"
                }
            }
        }

        stage('Backup Existing Production') {
            steps {
                script {
                    sh "mkdir -p ${BACKUP_DIR}"
                    if (sh(script: "docker ps -q -f name=${PROD_SERVER_NAME}", returnStatus: true) == 0) {
                        if (sh(script: "docker exec ${PROD_SERVER_NAME} ls /opt/minecraft/world", returnStatus: true) == 0) {
                            sh "docker cp ${PROD_SERVER_NAME}:/opt/minecraft/world ${BACKUP_DIR}/world_\"\$(date +'%Y%m%d_%H%M%S')\" || true"
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
                    // Zatrzymanie i usunięcie istniejącego serwera produkcyjnego
                    sh "docker stop ${PROD_SERVER_NAME} || true"
                    sh "docker rm ${PROD_SERVER_NAME} || true"
                    
                    // Wdrożenie na produkcję po zakończeniu testów
                    docker.image(IMAGE_NAME).run("-d --network ${NETWORK_NAME} -p 25565:25565 --name ${PROD_SERVER_NAME}")
                    
                    // Przywrócenie kopii zapasowej świata, jeśli istnieje
                    def latestBackup = sh(script: "ls -t ${BACKUP_DIR} | head -n 1", returnStdout: true).trim()
                    if (latestBackup) {
                        sh "docker cp ${BACKUP_DIR}/${latestBackup} ${PROD_SERVER_NAME}:/opt/minecraft/world"
                        echo "Przywrócono stan świata z kopii zapasowej: ${latestBackup}"
                    } else {
                        echo "Brak dostępnej kopii zapasowej do przywrócenia."
                    }
                    
                    // Wczytanie stanu świata po wdrożeniu
                    def worldState = sh(script: "docker exec ${PROD_SERVER_NAME} ls /opt/minecraft/world", returnStdout: true).trim()
                    echo "Stan świata po wdrożeniu: \n${worldState}"
                }
            }
        }

        stage('Monitor production server') {
            steps {
                script {
                    // Pobierz publiczny adres IP maszyny
                    def prodIP = sh(script: "curl -s ifconfig.me", returnStdout: true).trim()

                    // Sprawdzanie dostępności portu z zewnętrznej perspektywy
                    retry(5) {
                        if (sh(script: "nc -zv ${prodIP} 25565", returnStatus: true) != 0) {
                            echo "Port 25565 na adresie ${prodIP} nie jest dostępny. Próba ponowna."
                            sleep(time: 10, unit: 'SECONDS')
                            error("Port 25565 nie jest dostępny, ponawiam test.")
                        }
                    }
                }
            }
        }
    } // Zamyka sekcję stages
    
    post {
        always {
            script {
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
