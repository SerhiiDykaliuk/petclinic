pipeline {
    environment {
    registry = "docker_hub_account/repository_name"
    registryCredential = 'dockerhub'
    }

    node ('slave1') {

    	stage ('clinic1 - Checkout') {
    	 checkout([$class: 'GitSCM', branches: [[name: '*/main']], doGenerateSubmoduleConfigurations: false, extensions: [], submoduleCfg: [], userRemoteConfigs: [[credentialsId: 'git2', url: 'git@github.com:SerhiiDykaliuk/petclinic.git']]])
    	}
    	stage ('clinic1 - Build') {
    	    withMaven(maven: 'maven3') {
              sh "mvn clean package"
          }
    	}
    	stage('build image') {
    	    docker.withRegistry('https://registry.hub.docker.com', 'dockhub') {
    	        def customImage = docker.build("breeck/petclinic:v2")
    	        customImage.push()
    	    }
    	}
    }
}
