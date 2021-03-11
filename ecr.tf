# Provision an Elastic Container Registry (ECR)
# https://registry.terraform.io/providers/hashicorp/aws/latest/docs/resources/ecr_repository
# Making the tags immutable to prevent pushing over an existing tag
# https://docs.aws.amazon.com/AmazonECR/latest/userguide/image-tag-mutability.html
resource "aws_ecr_repository" "devops-bookstore-api" {
  name                 = "devops-bookstore-api"
  image_tag_mutability = "IMMUTABLE"
}