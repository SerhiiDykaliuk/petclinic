pipeline {
    agent {
        label 'slave1'
    }

    environment {
        SERVICE_CREDS = credentials('terraf-cr')
        DB_CREDS = credentials('database-cr')
        ECR_ADDR = "245715980904.dkr.ecr.us-west-2.amazonaws.com"
        ECR_REPO_NAME = "test-repo-1-prj-1"
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
        stage ('Build *.jar') {
            steps {
                withMaven(maven: 'maven3') {
                    sh "mvn clean test"
                }
            }
        }

        stage ('Build docker image') {
            steps {
                script {
                    app = docker.build("$ECR_ADDR/$ECR_REPO_NAME")
                }
            }
        }
        stage ('Push docker image'){
            steps {
                script {
                    def pomVer = readMavenPom file: 'pom.xml'
                    VERSION = pomVer.version
                    docker.withRegistry("https://$ECR_ADDR", 'ecr:us-west-2:ecr-cr') {
                        app.push("$VERSION")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Remove local images') {
            steps {
                script {
                  sh("docker rmi -f $ECR_ADDR/$ECR_REPO_NAME:latest")
                  sh("docker rmi -f $ECR_ADDR/$ECR_REPO_NAME:$VERSION")
                }
            }
        }
        stage ('Pull *.tf files') {
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
        stage('Run Terraform') {
            environment {
                AWS_ACCESS_KEY_ID = "$SERVICE_CREDS_USR"
                AWS_SECRET_ACCESS_KEY = "$SERVICE_CREDS_PSW"
                TF_VARS_db_user_name = "$DB_CREDS_USR"
                TF_VARS_db_user_password = "$DB_CREDS_PSW"
            }
            steps {
                sh "terraform init ./terraform/"
                sh "terraform apply -auto-approve ./terraform/"
            }
        }
    }
  //  post {
  //      always {
  //          deleteDir()
  //      }
  //  }
}
