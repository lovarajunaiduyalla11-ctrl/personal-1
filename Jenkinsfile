pipeline {
  agent any
  options { timestamps() }

  stages {
    stage('Checkout') {
      steps { checkout scm }
    }

    stage('Archive HTML') {
      steps {
        archiveArtifacts artifacts: 'index.html', fingerprint: true
      }
    }

    stage('Docker Build & Push') {
      steps {
        script {
          def tag = env.BUILD_NUMBER
          withCredentials([usernamePassword(credentialsId: 'docker-hub',
                                           usernameVariable: 'DH_USER',
                                           passwordVariable: 'DH_PASS')]) {
            sh """
              set -eux
              echo "\$DH_PASS" | docker login -u "\$DH_USER" --password-stdin
              
              # Build nginx image serving your static HTML
              docker build -t "\$DH_USER/myhome:${tag}" -t "\$DH_USER/myhome:latest" .
              
              # Push to Docker Hub
              docker push "\$DH_USER/myhome:${tag}"
              docker push "\$DH_USER/myhome:latest"
            """
            env.IMAGE_REPO = "${DH_USER}/myhome"
            env.IMAGE_TAG  = tag
          }
        }
      }
    }

    stage('Deploy to Docker Swarm') {
      steps {
        script {
          withCredentials([usernamePassword(credentialsId: 'docker-hub',
                                           usernameVariable: 'DH_USER',
                                           passwordVariable: 'DH_PASS')]) {
            sh """
              set -eux
              echo "\$DH_PASS" | docker login -u "\$DH_USER" --password-stdin
              
              docker swarm init 2>/dev/null || true
              
              # Deploy service (update if exists)
              docker service create --name myhome-web --replicas 2 -p 8080:80 \\
                  "\$DH_USER/myhome:${IMAGE_TAG}" || \\
              docker service update --image "\$DH_USER/myhome:${IMAGE_TAG}" myhome-web
            """
          }
        }
      }
    }
  }

  post {
    always { sh 'docker logout || true' }
  }
}
