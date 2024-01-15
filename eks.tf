resource "aws_iam_role" "postech" {
  name = "eks-cluster-postech"
  
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "eks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "postech-AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.postech.name
}

resource "aws_eks_cluster" "postech" {
  name     = "postech"
  role_arn = aws_iam_role.postech.arn

  vpc_config {
    endpoint_private_access = false
    endpoint_public_access  = true
    security_group_ids      = [aws_security_group.node_group_one.id]

    subnet_ids = [
      aws_subnet.private-us-east-1a.id,
      aws_subnet.private-us-east-1b.id,
      aws_subnet.public-us-east-1a.id,
      aws_subnet.public-us-east-1b.id
    ]
  }

  depends_on = [aws_iam_role_policy_attachment.postech-AmazonEKSClusterPolicy]
}

resource "aws_security_group" "node_group_one" {
  name_prefix = "node_group_one"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port = 80
    to_port   = 80
    protocol  = "tcp"

    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

