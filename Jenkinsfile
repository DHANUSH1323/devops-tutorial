pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-2'
        IMAGE_TAG             = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Build & Test') {
            steps {
                dir('app') {
                    sh 'mvn -B clean package'
                }
            }
            post {
                always {
                    junit 'app/target/surefire-reports/*.xml'
                }
            }
        }

        stage('Docker Build') {
            steps {
                dir('app') {
                    sh 'docker build --platform=linux/amd64 -t devops-app:${IMAGE_TAG} .'
                }
            }
        }

        stage('Push to ECR') {
            steps {
                script {
                    def accountId = sh(script: 'aws sts get-caller-identity --query Account --output text', returnStdout: true).trim()
                    env.ECR_HOST = "${accountId}.dkr.ecr.us-east-2.amazonaws.com"
                    env.ECR_URL  = "${env.ECR_HOST}/devops-app"
                }
                sh '''
                    aws ecr get-login-password --region us-east-2 \
                      | docker login --username AWS --password-stdin "$ECR_HOST"
                    docker tag devops-app:${IMAGE_TAG} "$ECR_URL:${IMAGE_TAG}"
                    docker tag devops-app:${IMAGE_TAG} "$ECR_URL:latest"
                    docker push "$ECR_URL:${IMAGE_TAG}"
                    docker push "$ECR_URL:latest"
                '''
            }
        }

        stage('Terraform Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Terraform Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Terraform Plan') {
            steps {
                sh "terraform plan -var image_tag=${IMAGE_TAG} -out=tfplan -input=false"
            }
        }

        stage('Approval') {
            steps {
                input message: 'Apply Terraform changes?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                sh 'terraform apply -input=false -auto-approve tfplan'
            }
        }
    }
}
