pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-2'
        SONAR_TOKEN           = credentials('SONAR_TOKEN')
        SONAR_HOST_URL        = 'http://sonarqube:9000'
        IMAGE_TAG             = "${env.BUILD_NUMBER}"
    }

    stages {
        stage('Lint') {
            steps {
                dir('app') {
                    sh '''
                        docker run --rm \
                          --network devops-net \
                          --volumes-from jenkins \
                          -w "$PWD" \
                          python:3.12-slim \
                          bash -lc "pip install --quiet --index-url http://nexus:8081/repository/pypi-proxy/simple/ --trusted-host nexus ruff==0.6.9 && ruff check ."
                    '''
                }
            }
        }

        stage('Unit Tests') {
            steps {
                dir('app') {
                    sh '''
                        docker run --rm \
                          --network devops-net \
                          --volumes-from jenkins \
                          -w "$PWD" \
                          python:3.12-slim \
                          bash -lc "pip install --quiet --index-url http://nexus:8081/repository/pypi-proxy/simple/ --trusted-host nexus -r requirements-dev.txt && pytest --junitxml=test-results.xml --cov=. --cov-report=xml"
                    '''
                }
            }
            post {
                always {
                    junit 'app/test-results.xml'
                }
            }
        }

        stage('SonarQube Analysis') {
            steps {
                dir('app') {
                    withSonarQubeEnv('SonarQube') {
                        sh '''
                            docker run --rm \
                              --volumes-from jenkins \
                              --network=devops-net \
                              -w "$PWD" \
                              -e SONAR_HOST_URL="$SONAR_HOST_URL" \
                              -e SONAR_TOKEN="$SONAR_AUTH_TOKEN" \
                              sonarsource/sonar-scanner-cli
                        '''
                    }
                }
            }
        }

        stage('Quality Gate') {
            steps {
                timeout(time: 3, unit: 'MINUTES') {
                    waitForQualityGate abortPipeline: true
                }
            }
        }

        stage('Terraform Init') {
            steps {
                dir('envs/dev') {
                    sh 'terragrunt init -input=false -reconfigure'
                }
            }
        }

        stage('Terraform Validate') {
            steps {
                dir('envs/dev') {
                    sh 'terragrunt validate'
                }
            }
        }

        stage('Ensure ECR Repo Exists') {
            steps {
                dir('envs/dev') {
                    sh 'terragrunt apply -input=false -auto-approve -target=module.ecr.aws_ecr_repository.app'
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

        stage('Image Scan') {
            steps {
                sh '''
                    docker run --rm \
                      -v /var/run/docker.sock:/var/run/docker.sock \
                      aquasec/trivy:latest image \
                      --severity HIGH,CRITICAL \
                      --no-progress \
                      --exit-code 0 \
                      devops-app:${IMAGE_TAG}
                '''
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
                '''
                retry(5) {
                    sh '''
                        docker push "$ECR_URL:${IMAGE_TAG}"
                        docker push "$ECR_URL:latest"
                    '''
                }
            }
        }

        stage('Terraform Plan') {
            steps {
                dir('envs/dev') {
                    sh "terragrunt plan -var image_tag=${IMAGE_TAG} -out=tfplan -input=false"
                }
            }
        }

        stage('Approval') {
            steps {
                input message: 'Apply Terraform changes?', ok: 'Apply'
            }
        }

        stage('Terraform Apply') {
            steps {
                dir('envs/dev') {
                    sh 'terragrunt apply -input=false -auto-approve tfplan'
                }
            }
        }
    }
}
