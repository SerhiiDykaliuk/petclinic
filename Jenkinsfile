pipeline {
    agent {
        label 'slave1'
    }
    environment {
        SERVICE_CREDS = credentials('terraf-cr')
    }
    stages {
        stage ('petclinic Checkout') {
            steps {
 	            checkout([$class: 'GitSCM',
                branches: [[name: '*/main']],
                doGenerateSubmoduleConfigurations: false,
                extensions: [], submoduleCfg: [],
                userRemoteConfigs: [[credentialsId: 'git2', url: 'git@github.com:SerhiiDykaliuk/petclinic.git']]])
            }
        }
        stage ('build jar') {
            steps {
                withMaven(maven: 'maven3') {
                    sh "mvn clean package"
                }
            }
        }
        stage ('docker') {
            steps {
                sh "docker build -t 245715980904.dkr.ecr.us-west-2.amazonaws.com/test-repo-1-prj-1:latest ."
                script {
                    docker.withRegistry('https://245715980904.dkr.ecr.us-west-2.amazonaws.com', 'ecr:us-west-2:ecr-cr') {
                        sh "docker push 245715980904.dkr.ecr.us-west-2.amazonaws.com/test-repo-1-prj-1:latest"
                    }
                }
            }
        }
        stage ('pull tf') {
            steps {
                dir ('terraform') {
                    checkout([$class: 'GitSCM',
                    branches: [[name: '*/main']],
                    doGenerateSubmoduleConfigurations: false,
                    extensions: [], submoduleCfg: [],
                    userRemoteConfigs: [[credentialsId: 'gitter', url: 'git@github.com:SerhiiDykaliuk/repo.git']]])
                }
            }
        }
        stage('run TF') {
            environment {
                AWS_ACCESS_KEY_ID = "$SERVICE_CREDS_USR"
                AWS_SECRET_ACCESS_KEY = "$SERVICE_CREDS_PSW"
            }
            steps {
                sh "terraform init ./terraform/"
                sh "terraform apply -auto-approve ./terraform/"
            }
        }
    }
}
