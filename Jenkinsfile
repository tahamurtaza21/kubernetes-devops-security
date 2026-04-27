pipeline {
  agent any

  stages {
      stage('Build Artifact') {
            steps {
              sh "mvn clean package -DskipTests=true"
              archive 'target/*.jar' //so that they can be downloaded later
            }
        }
      stage('Unit Tests') {
                  steps {
                    sh "mvn test jacoco:report"
                  }
//                  post{
//                    always{
//                        junit 'target/surefire-reports/*.xml'
//                        jacoco execPattern: 'target/jacoco.exec'
//                    }
//                  }
              }

      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
//            post{
//              always{
//                  pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
//              }
//            }
          }

      stage('SonarQube - SAST')
      {
        steps
        {
            withSonarQubeEnv('SonarQube')
            {
            sh "mvn sonar:sonar \
                 -Dsonar.projectKey=Numeric-Application \
                 -Dsonar.host.url=http://192.168.79.137:9000"
            }
            timeout(time: 2, unit: 'MINUTES')
            {
                script
                {
                    waitForQualityGate abortPipeline: true
                }
            }
        }
      }

//      stage('Vulnerability Scan - Docker') {
//          steps {
//              withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
//                  sh "mvn dependency-check:check -DnvdApiKey=$NVD_API_KEY"
//              }
//          }
//          post {
//              always {
//                  dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
//              }
//          }
//      }

      stage('Vulnerability Scan - Docker') {
          steps {
              parallel(
                  "Dependency Check": {
                      withCredentials([string(credentialsId: 'NVD_API_KEY', variable: 'NVD_API_KEY')]) {
                          sh "mvn dependency-check:check -DnvdApiKey=$NVD_API_KEY"
                      }
                  },
                  "Trivy Scan": {
                      sh "bash trivy-docker-image-scan.sh"
                  },
                  "OPA ConfTest": {
                      sh "docker run --rm -v '${WORKSPACE}:/project' openpolicyagent/conftest:v0.45.0 test --policy opa-docker-security.rego Dockerfile"
                  }
              )
          }
      }


      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t tahamur27/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push tahamur27/numeric-app:""$GIT_COMMIT""'
              }
            }
          }

      stage('Kubernetes Deployment - DEV') {
            steps {
              withKubeConfig([credentialsId: 'jenkins-sa-token', serverUrl: 'https://192.168.79.141:6443']) {
                sh "sed -i 's#replace#tahamur27/numeric-app:${GIT_COMMIT}#g' k8s_deployment_service.yaml"
                sh "kubectl apply -f k8s_deployment_service.yaml"
              }
            }
          }
    }

    post
    {
        always {
            junit 'target/surefire-reports/*.xml'
            jacoco execPattern: 'target/jacoco.exec'
            pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
            dependencyCheckPublisher pattern: 'target/dependency-check-report.xml'
        }

//        success {
//
//        }
//
//        failure {
//
//        }
    }
}