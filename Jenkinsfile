pipeline {
    agent {
        label 'master'
    }

    environment {
        DB_CREDS = credentials('database-cr')
    }
    stages {
        stage ('petclinic Checkout') {
            steps {
 	            checkout([$class: 'GitSCM',
                branches: [[name: '*/main']],
                doGenerateSubmoduleConfigurations: false,
                extensions: [], submoduleCfg: [],
                userRemoteConfigs: []])
            }
        }
        stage ('Build *.jar') {
            steps {
                withMaven(maven: 'maven3') {
                    sh "mvn clean package"
                }
            }
            post {
                always {
                    junit 'target/surefire-reports/*.xml'
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
                        app.push("$VERSION-BN$BUILD_NUMBER")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Remove local images') {
            steps {
                script {
                  sh("docker rmi -f $ECR_ADDR/$ECR_REPO_NAME:latest")
                  sh("docker rmi -f $ECR_ADDR/$ECR_REPO_NAME:$VERSION-BN$BUILD_NUMBER")
                }
            }
        }
    }
    post {
        always {
            deleteDir()
        }
    }
}
