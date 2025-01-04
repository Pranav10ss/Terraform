resource "aws_iam_role" "test_role_1" {
  name = "webserver1_role"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  tags = var.tags
}

resource "aws_iam_policy" "policy1" {
  name        = "test_policy1"
  path        = "/"
  description = "Policy to allow webserver1 to access s3"

  # Terraform's "jsonencode" function converts a
  # Terraform expression result to valid JSON syntax.
  policy = jsonencode({
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "Statement1",
			"Effect": "Allow",
			"Action": [
				"s3:ListBucket",
				"s3:GetObject",
				"s3:PutObject"
			],
			"Resource": [
				"*"
			]
		}
	]
})
}

resource "aws_iam_role_policy_attachment" "test-attach-1" {
  role       = aws_iam_role.test_role_1.name
  policy_arn = aws_iam_policy.policy1.arn
  depends_on = [ aws_iam_role.test_role_1, aws_iam_policy.policy1]
}

resource "aws_iam_instance_profile" "webserver1_role" {
  name = "test_profile1"
  role = aws_iam_role.test_role_1.name
}

