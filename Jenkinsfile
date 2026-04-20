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

      stage('Docker Build and Push') {
            steps {
              withDockerRegistry([credentialsId: "docker-hub", url: ""]) {
                sh 'printenv'
                sh 'docker build -t tahamur27/numeric-app:""$GIT_COMMIT"" .'
                sh 'docker push tahamur27/numeric-app:""$GIT_COMMIT""'

              }
            }
          }
    }
}