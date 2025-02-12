pipeline {
    agent any 
   
    stages { 

        stage('Build docker image') {
            steps {  
                sh 'docker build -t nenejalloh/flask:$BUILD_NUMBER .'
            }
        }

        stage('Login to DockerHub') {
            steps {
                sh 'echo $DOCKERHUB_CREDENTIALS_PSW | docker login -u $DOCKERHUB_CREDENTIALS_USR --password-stdin'
            }
        }
         stage('Scan Docker Image') {
            steps {
                script {
                    try {
                        def trivyOutput = sh(script: "trivy image --severity HIGH,CRITICAL nenejalloh/flask:$BUILD_NUMBER", returnStdout: true).trim()
                        println trivyOutput
                        if (trivyOutput.contains("Total: 0")) {
                            echo "No high or critical vulnerabilities found in the Docker image."
                        } else {
                            echo "High or critical vulnerabilities found in the Docker image."
                            // Uncomment the next line to fail the build if vulnerabilities are found
                            // error "Vulnerabilities found in the Docker image."
                        }
                    } catch (Exception e) {
                        error "Error scanning Docker image: ${e.message}"
                    }
                }
            }
        }

        stage('Push image') {
            steps {
                sh 'docker push nenejalloh/flask:$BUILD_NUMBER'
            }
        }
    }

    post {
        always {
            sh 'docker rmi nenejalloh/flask:$BUILD_NUMBER || true'
            sh 'docker logout'
        }
    }
}
