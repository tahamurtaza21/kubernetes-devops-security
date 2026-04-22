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
                  post{
                    always{
                        junit 'target/surefire-reports/*.xml'
                        jacoco execPattern: 'target/jacoco.exec'
                    }
                  }
              }

      stage('Mutation Tests - PIT') {
            steps {
              sh "mvn org.pitest:pitest-maven:mutationCoverage"
            }
            post{
              always{
                  pitmutation mutationStatsFile: '**/target/pit-reports/**/mutations.xml'
              }
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
}