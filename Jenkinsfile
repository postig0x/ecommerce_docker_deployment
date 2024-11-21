pipeline {
  agent any

  environment {
    DOCKER_CREDS = credentials('docker-hub-credentials')
  }

  stages {
    stage ('Build') {
      agent any
      when {
        branch 'main'
      }
      steps {
        dir('backend') {
          sh '''#!/bin/bash
          python3.9 -m venv venv
          source venv/bin/activate
          pip install -r requirements.txt
          '''
        }
      }
    }

    stage ('Test') {
      agent any
      when {
        branch 'main'
      }
      environment {
        DJANGO_TEST_ENV = 'true'
      }
      steps {
        dir('backend') {
          sh '''#!/bin/bash
          source venv/bin/activate
          pip install pytest-django
          python manage.py makemigrations
          python manage.py migrate
          pytest account/tests.py --verbose --junit-xml test-reports/results.xml
          ''' 
        }
      }
    }

    stage('Cleanup') {
      agent { label 'build-node' }
      when {
        branch 'main'
      }
      steps {
        sh '''
          # Only clean Docker system
          docker system prune -f
          
          # Safer git clean that preserves terraform state
          git clean -ffdx -e "*.tfstate*" -e ".terraform/*"
        '''
      }
    }

    stage('Build & Push Images') {
      agent { label 'build-node' }
      when {
        branch 'main'
      }
      steps {
        sh 'echo ${DOCKER_CREDS_PSW} | docker login -u ${DOCKER_CREDS_USR} --password-stdin'
        
        // Build and push backend
        sh '''
          docker build -t postig0x/ecomm_back:latest -f Dockerfile.backend .
          docker push postig0x/ecomm_back:latest
        '''
        
        // Build and push frontend
        sh '''
          docker build -t postig0x/ecomm_front:latest -f Dockerfile.frontend .
          docker push postig0x/ecomm_front:latest
        '''
      }
    }

    stage('Infrastructure') {
      agent { label 'build-node' }
      when {
        branch 'main'
      }
      steps {
        dir('Terraform') {
          sh '''
            terraform init
            terraform apply -auto-approve \
              -var="docker_user=${DOCKER_CREDS_USR}" \
              -var="docker_pass=${DOCKER_CREDS_PSW}"
          '''
        }
      }
    }
  }

  post {
    always {
      agent { label 'build-node' }
      when {
        branch 'main'
      }
      steps {
        sh '''
          docker logout
          docker system prune -f
        '''
      }
    }
  }
}
