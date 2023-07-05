pipeline {
    agent any
    environment {
        TEST_SRV_IP = '3.84.32.91'
        PROD_SRV_IP = '107.20.0.154'
        AWS_DEFAULT_REGION = 'us-east-1'
    }
    stages {
        stage('Cleanup') {
            steps {
                sh 'echo "Performing cleanup..."'
                sh 'rm -rf *'
                sh 'docker image prune -a -f '
                sh 'docker container prune -f '
            }
        }
        stage('Clone') {
            steps {
                sh 'echo "Building..."'
                sh 'git clone https://github.com/rommanor/final-pro.git'
                
            }
        }
        stage('Build Docker Image') {
            steps {
                sh 'echo "Building Docker image..."'
                dir('final-pro') {
                    sh "docker build -t rommanor/final-pro:latest ."
                }
            }
        }
        stage('Push Docker Image') {
            steps {
                sh 'echo "Pushing Docker image to Docker Hub..."'
                withCredentials([usernamePassword(credentialsId: 'docker-hub-credentials', usernameVariable: 'DOCKER_USERNAME', passwordVariable: 'DOCKER_PASSWORD')]) {
                    sh '''
                    docker login -u ${DOCKER_USERNAME} -p ${DOCKER_PASSWORD}
                    docker push rommanor/final-pro
                    '''
                }
            }
        }
        stage('prep test srv') {
          steps {
           script{
            sh 'echo "Pulling Docker image from Docker Hub..."'
            sh '''
            ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/rom01.pem ec2-user@${TEST_SRV_IP} '
            sudo yum install docker -y
            sudo systemctl restart docker
            sudo docker run -d -p 5000:5000 --rm --name my-container rommanor/final-pro
            '
            '''
        }
    }
}
        stage('Testing') {
    steps {
        script {
            def response = sh(returnStatus: true, script: "curl -s -o /dev/null -w '%{http_code}' ${TEST_SRV_IP}:5000")
            if (response == 0) {
                echo 'Flask app returned a 200 status code. Test passed!'
            } else {
                echo "Curl command failed with exit code: ${response}"
                error('Test failed!') // Abort the pipeline with an error status
            }
        }
    }
}


stage('deploy to prod') {
    steps {
           script{
            sh '''
            ssh -o StrictHostKeyChecking=no -i /var/lib/jenkins/rom01.pem ec2-user@${PROD_SRV_IP} '
            sudo dnf update -y
            sudo dnf install docker -y
            sudo systemctl start docker
            sudo systemctl ensble docker
            docker stop \$(docker ps -q)
            sudo docker run -d -p 5000:5000 --rm --name my-container rommanor/final-pro
            '
            '''
            }
        }
    }
}
}
