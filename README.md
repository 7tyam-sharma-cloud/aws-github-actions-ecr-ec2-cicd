# End-to-End AWS CI/CD: GitHub Actions -> Docker -> ECR -> EC2

This portfolio project tests a Flask app, builds a Docker image, pushes it to Amazon ECR, and deploys it to an Ubuntu EC2 instance. GitHub Actions authenticates to AWS using OIDC. Deployment commands reach EC2 through AWS Systems Manager (no inbound SSH required).

## Architecture

GitHub push -> GitHub Actions -> unit tests -> Docker build -> Amazon ECR -> AWS Systems Manager -> EC2 Docker container -> public HTTP application.

Terraform provisions the ECR repository, EC2 instance, security group, IAM roles, GitHub OIDC provider and GitHub Actions deployment role.

## Prerequisites

- AWS account and permissions to create IAM, EC2, ECR, and SSM resources.
- AWS CLI, Terraform 1.5+, Git, Docker.
- GitHub account and repository.
- A default VPC with at least one public subnet. The EC2 instance needs outbound internet access to install packages and pull images.

## 1. Create GitHub repository

Create a public or private repository named `github-actions-ec2-cicd`. Upload the project files, preserving `.github/workflows/deploy.yml`.

## 2. Provision AWS infrastructure

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Edit `terraform.tfvars` with your GitHub username and repository name. Then:

```bash
aws configure
terraform init
terraform fmt -recursive
terraform validate
terraform plan
terraform apply
```

Review the plan and type `yes`. Save the output values:
- `github_actions_role_arn`
- `ecr_repository_name`
- `ec2_instance_id`
- `application_url`

If your AWS account already has the GitHub Actions OIDC provider, import that provider into Terraform state or adapt the configuration to reuse it instead of creating a duplicate.

## 3. Configure GitHub repository variables and secret

In GitHub, open repository -> Settings -> Secrets and variables -> Actions.

Add **Variables**:
- `AWS_REGION`: same region used in Terraform, e.g. `ap-south-1`
- `ECR_REPOSITORY`: Terraform output `ecr_repository_name`
- `EC2_INSTANCE_ID`: Terraform output `ec2_instance_id`

Add **Secret**:
- `AWS_DEPLOY_ROLE_ARN`: Terraform output `github_actions_role_arn`

No long-lived AWS access key is required. GitHub Actions obtains short-lived AWS credentials through OIDC.

## 4. Run the workflow

Push to the `main` branch:

```bash
git add .
git commit -m "Add AWS EC2 CI/CD pipeline"
git push origin main
```

Open GitHub -> Actions -> Build and Deploy to AWS EC2. Watch each stage:
1. Checkout source.
2. Install Python dependencies and run unit tests.
3. Assume the AWS IAM role using GitHub OIDC.
4. Authenticate to ECR.
5. Build and push the Docker image tagged with the commit SHA.
6. Send deployment commands to EC2 using SSM.
7. Pull the image and restart the application container on port 80.

## 5. Verify live application

Open the `application_url` Terraform output in a browser. The root path returns JSON. Add `/health` to test the health endpoint.

Change the message in `app.py`, commit, and push again. A new workflow run should deploy the updated version.

## Troubleshooting

- **OIDC AccessDenied:** verify repository owner/name, branch, role ARN, `id-token: write`, and the IAM trust policy.
- **SSM target offline:** check that the EC2 instance has an instance profile with `AmazonSSMManagedInstanceCore`, SSM Agent is running, and outbound HTTPS is available.
- **ECR login/push denied:** inspect the GitHub role's ECR permissions and confirm region/repository variables.
- **EC2 ECR pull denied:** inspect the EC2 role's ECR pull policy.
- **Application not reachable:** confirm EC2 is in a public subnet, has a public IP, port 80 is allowed, and the container is running.
- **Terraform OIDC provider already exists:** reuse/import the existing provider rather than creating a duplicate.

## Cost and security notes

This project creates billable AWS resources (EC2, ECR storage, and data transfer). Use a small test environment, monitor AWS Billing, and destroy resources after testing. The demo allows public HTTP on port 80; do not use it for sensitive production workloads. Use HTTPS, a domain, tighter IAM permissions, image scanning, and deployment approvals for production.

## Cleanup

```bash
cd terraform
terraform destroy
```

Review the resources before confirming. Check ECR and AWS Billing for any remaining resources.

## Resume description

Designed and implemented an automated CI/CD pipeline using GitHub Actions, Docker, Amazon ECR, and Amazon EC2. Integrated GitHub OIDC for secure AWS authentication and AWS Systems Manager for remote deployment. Used Terraform to provision cloud infrastructure and automated unit testing, image publishing, and application deployment.

## Interview explanation

"When I push code to the main branch, GitHub Actions starts the workflow. It runs Python unit tests, builds a Docker image, and pushes that image to Amazon ECR. GitHub Actions authenticates to AWS using OIDC and uses Systems Manager to instruct EC2 to pull and run the new image. Terraform provisions the AWS infrastructure. The application is then available through the EC2 public IP on port 80."
