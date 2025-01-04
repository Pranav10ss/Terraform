# Load balancing incoming HTTP traffic to EC2 instances across public subnets
## Purpose of the project
The primary goal of this project is to demonstrate how to design and implement a highly available and scalable architecture using AWS services. By distributing incoming HTTP traffic across multiple EC2 instances in different public subnets of a VPC, the project ensures improved reliability and fault tolerance. The key objectives of the project include:
1. **Load Balancing**: Efficiently distributing incoming traffic to ensure no single instance is overwhelmed.
2. **High Availability**: Hosting EC2 instances across multiple availability zones to minimize downtime.
3. **Scalability**: Allowing seamless handling of increased traffic by adding more EC2 instances if needed.
4. **Network Accessibility**: Ensuring the VPC is internet-accessible using an Internet Gateway.
## Architecture
1. **Application Load Balancer (ALB)**:
   * Configured to distribute incoming HTTP traffic evenly across the EC2 instances.
   * Health checks are configured to monitor the instances' availability.
2. **Terraform:**
   * Used as the Infrastructure as Code (IaC) tool to automate the deployment of resources.
# Conclusion
This project successfully demonstrates the use of Terraform to build a load-balanced, highly available architecture on AWS. By distributing HTTP traffic across multiple EC2 instances in different availability zones, the architecture provides improved scalability, fault tolerance, and performance. The integration of Terraform ensures that the infrastructure is easily reproducible and maintainable, making it suitable for real-world production environments. Overall, this setup is a foundational example of designing resilient web applications in the cloud.
