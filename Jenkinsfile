pipeline {
    agent {
        label 'slave1'
    }

    environment {
        SERVICE_CREDS = credentials('terraf-cr')
        DB_CREDS = credentials('database-cr')
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
                script {
                    app = docker.build("245715980904.dkr.ecr.us-west-2.amazonaws.com/test-repo-1-prj-1")
                }
            }
        }
        stage ('docker push'){
            steps {
                script {
                    GIT_COMMIT_HASH_SHORT = sh (script: "git log -n 1 --pretty=format:'%h'", returnStdout: true)
                    docker.withRegistry('https://245715980904.dkr.ecr.us-west-2.amazonaws.com', 'ecr:us-west-2:ecr-cr') {
                        app.push("$GIT_COMMIT_HASH_SHORT")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Remove local images') {
            steps {
                sh("docker rmi -f 245715980904.dkr.ecr.us-west-2.amazonaws.com/test-repo-1-prj-1:latest")
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
                TF_VARS_db_user_name = "$DB_CREDS_USR"
                TF_VARS_db_user_password = "$DB_CREDS_PSW"
            }
            steps {
                sh "terraform init ./terraform/"
                sh "terraform apply -auto-approve ./terraform/"
            }
        }
    }
    post {
        always {
            deleteDir()
        }
    }
}
