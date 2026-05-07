pipeline {
    agent any

    environment {
        AWS_ACCESS_KEY_ID     = credentials('AWS_ACCESS_KEY_ID')
        AWS_SECRET_ACCESS_KEY = credentials('AWS_SECRET_ACCESS_KEY')
        AWS_DEFAULT_REGION    = 'us-east-2'
    }

    stages {
        stage('Init') {
            steps {
                sh 'terraform init -input=false'
            }
        }

        stage('Validate') {
            steps {
                sh 'terraform validate'
            }
        }

        stage('Plan') {
            steps {
                sh 'terraform plan -out=tfplan -input=false'
            }
        }

        stage('Approval') {
            when { branch 'main' }
            steps {
                input message: 'Apply Terraform changes?', ok: 'Apply'
            }
        }

        stage('Apply') {
            when { branch 'main' }
            steps {
                sh 'terraform apply -input=false -auto-approve tfplan'
            }
        }
    }
}
