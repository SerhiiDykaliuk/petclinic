pipeline {
    agent {
        label 'master'
    }

    environment {
        // DB_CREDS = credentials('database-cr')
        HUBUNAME = "breeck"
        REPONAME = "petclinic"
    }
    stages {
        stage ('clean') {
            steps {
                cleanWs()
            }
        }

        stage ('petclinic Checkout') {
            steps {
 	            checkout([$class: 'GitSCM',
                branches: [[name: '*/gcp']],
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
                    app = docker.build("$HUBUNAME/$REPONAME")
                }
            }
        }
        stage ('Push docker image'){
            steps {
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'dockerhub-creds') {
                        // app.push("$VERSION-BN$BUILD_NUMBER")
                        app.push("latest")
                    }
                }
            }
        }
        stage('Remove local images') {
            steps {
                script {
                  sh("docker rmi -f $HUBUNAME/$REPONAME:latest")
                }
            }
        }
    }
}
