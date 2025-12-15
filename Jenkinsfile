pipeline{
    agent{
        label "jenkins-agent"
    }
    tools {
        jdk 'Java17'
        maven 'Maven3'
    }
    environment {
        APP_NAME = "nhom18-projects"
        RELEASE = "1.0.0"
        DOCKER_USER = "nhom18-projects"
        DOCKER_PASS = 'dockerhub'
        IMAGE_NAME = "${DOCKER_USER}" + "/" + "${APP_NAME}"
        IMAGE_TAG = "${RELEASE}-${BUILD_NUMBER}"
        JENKINS_API_TOKEN = credentials('JENKINS_API_TOKEN')

    }
    stages{
        stage("Cleanup Workspace"){
            steps {
                cleanWs()
            }

        }
        /*stage("Checkout from SCM"){
            steps {
                git branch: 'main', credentialsId: 'github-token', url: 'https://github.com/nhanalvth/minhnhan548'
            }

        }*/
        stage("Checkout from SCM") {
            steps {
                git url: 'https://github.com/nhanalvth/nhom18-projects', branch: 'main', credentialsId: 'github-token'
            }
        }

        stage("Build Application"){
            steps {
                sh "mvn clean package"
            }

        }

        stage("Test Application"){
            steps {
                sh "mvn test"
            }

        }
        stage("Sonarqube Analysis") {
            steps {
                script {
                    withSonarQubeEnv(credentialsId: 'jenkins-sonarqube-token') {
                        sh "mvn sonar:sonar"
                    }
                }
            }

        }
        /*stage("Quality Gate") {
            steps {
                script {
                    def qualityGateStatus = waitForQualityGate(credentialsId: 'jenkins-sonarqube-token')
                    if (qualityGateStatus == 'OK') {
                        echo "Quality Gate Passed"
                    } else {
                        echo "Quality Gate Failed"
                        currentBuild.result = 'FAILURE'
                        // Dừng pipeline nếu không đạt chất lượng
                        error("Quality Gate failed, stopping pipeline")
                    }
                }
            }
        }*/
        stage("Quality Gate") {
            steps {
                script {
                    def qg = waitForQualityGate()
                    if (qg.status != 'OK') {
                        error "Quality Gate failed: ${qg.status}"
                    } else {
                        echo "Quality Gate Passed"
                    }
                }
            }
        }

        stage("Build & Push Docker Image") {
            steps {
                script {
                    def IMAGE_NAME = "${DOCKER_USER}/${APP_NAME}"
                    def IMAGE_TAG = "${RELEASE}-${env.BUILD_NUMBER}"
                    
                    docker.withRegistry('', DOCKER_PASS) {
                        def docker_image = docker.build("${IMAGE_NAME}")
                        docker_image.push("${IMAGE_TAG}")
                        docker_image.push('latest')
                    }
                }
            }
        }
        
        stage("Trigger CD Pipeline") {
            steps {
                script {
                    sh "curl -v -k --user admin:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data 'IMAGE_TAG=${IMAGE_TAG}' 'http://192.168.1.10:8080/job/gitops-complete-prodcution-e2e-pipeline-main/buildWithParameters?token=gitops-token'"
                    //sh "curl -v -k --user admin:${JENKINS_API_TOKEN} -X POST -H 'cache-control: no-cache' -H 'content-type: application/x-www-form-urlencoded' --data \"IMAGE_TAG=${IMAGE_TAG}\" \"http://192.168.1.10:8080/job/Gitops/buildWithParameters?token=gitops-token\""

                }
            }

        }

    }
    
}