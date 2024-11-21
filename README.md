# E-Commerce Docker Deployment

## Purpose

The purpose of this project is to create a more distributed application deployment architecture for an e-commerce platform. This includes setting up infrastructure using Terraform, creating Docker containers for the frontend and backend, and implementing Jenkins for continuous integration (CI) and automated deployment.

Key aspects include:

- A distributed application architecture with cloud-based infrastructure
- Automation of application build and deployment processes through Jenkins
- Docker containerization for better scalability and portability
- Terraform for infrastructure management

## Steps

### 1. Terraform Infrastructure Setup

The infrastructure was provisioned using Terraform, with the following layout in AWS (Amazon Web Services):

- **1 Custom VPC**: Located in the `us-east-1` region
- **2 Availability Zones**: `us-east-1a` and `us-east-1b`
- **Subnets**: 
  - 1 private subnet and 1 public subnet in each Availability Zone
- **EC2 Instances**: 
  - 1 Bastion host in the public subnet (for secure SSH access)
  - 1 Application server in the private subnet
- **Load Balancer**: Used to distribute inbound traffic to the application instances
- **RDS Database Instance**: Managed relational database service for the backend database

### 2. Docker Setup

Docker containers were used to deploy the application in a scalable and isolated environment.

- **Environment Variable `$MIGRATE_DB`**: This environment variable is defined in the `Terraform/compose.yml` file to handle database migrations. Only the first app instance needs to perform the migration to ensure the RDS database instance is in sync across all instances.
  
- **Docker Hub Integration**:
  - An access token was generated for Docker Hub to store sensitive credentials.
  - Docker images for the frontend and backend were created in the `Docker_Terraform` instance, then pushed to Docker Hub.
  - The images were named `postig0x/ecomm_front` for the frontend and `postig0x/ecomm_back` for the backend.
  
- **Deployment**: 
  - Once the images were available on Docker Hub, instances could pull them using the command `docker compose pull`.
  - The `Terraform/deploy.sh` script handles the deployment process of the Docker containers to the EC2 instances.

### 3. Jenkins Setup

Jenkins was used for continuous integration (CI), though it required some adjustments for optimal performance:

- **Jenkins Manager Configuration**:
  - The Jenkins manager was slow for this workload, requiring manual updates of the Jenkins configuration file (`/var/lib/jenkins/jenkins.model.JenkinsLocationConfiguration.xml`) to reflect the correct public IP address of the instance.
  - To automate this, an environment variable `export PUBLIC_IP=$(curl ifonfig.me)` was created, and a crontab entry was added: `@reboot /home/ubuntu/scripts/jenkinsConfig.patch` to update the configuration file on startup.
  
- **Jenkinsfile Adjustments**: 
  - A build stage was added to the Jenkinsfile, which activates the Python environment and installs backend dependencies.
  - A new environment variable `DJANGO_TEST_ENV` was created to control the test environment configuration. In the `backend/my_project/settings.py`, the following logic was added to check the value of this environment variable:

    ```python
    isTesting = os.environ.get('DJANGO_TEST_ENV', 'false').lower() == 'true'
    ```

    - This prevents errors during database migrations and testing.
  
  - Additionally, a `pytest.ini` file was created to configure the test environment and define missing settings, particularly for the `DJANGO_SETTINGS_MODULE`.

## System Design Diagram

![System Design Diagram](/screenshots/workload6.png)

## Issues / Troubleshooting

- **Jenkins Test Stage**: The main issue encountered was with the `settings.py` file for the Django application, particularly in making sure the Jenkins test stage ran successfully without database-related errors. 
  - The issue was resolved by properly configuring the `DJANGO_TEST_ENV` environment variable to enable the correct test settings in the `settings.py` file.
  
## Optimization

- **Security Improvements**: 
  - The frontend and backend could be deployed to separate subnets to increase security by isolating the two components.
  
- **Database Optimization**: 
  - The RDS database can be moved to its own private subnet, reducing its exposure to external traffic and further increasing security.

## Conclusion

This project successfully deployed an e-commerce application using Docker for containerization, Terraform for infrastructure automation, and Jenkins for CI/CD. Although there were challenges, particularly with Jenkins and database migrations, the deployment is functional and can be further optimized for scalability and security.

Moving forward, we can continue improving the infrastructure by isolating components in different subnets, which would enhance security and performance.
