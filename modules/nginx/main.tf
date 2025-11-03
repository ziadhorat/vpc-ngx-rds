data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "nginx" {
  name        = "${var.project_name}-nginx-sg"
  description = "Nginx web server"
  vpc_id      = var.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nginx-sg"
  })
}

resource "aws_iam_role" "nginx" {
  name = "${var.project_name}-nginx-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
    }]
  })
  tags = var.common_tags
}

resource "aws_iam_role_policy" "nginx" {
  name = "${var.project_name}-nginx-policy"
  role = aws_iam_role.nginx.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ssm:GetParameter",
          "ssm:GetParameters"
        ]
        Resource = [
          "arn:aws:ssm:${var.aws_region}:${var.aws_account_id}:parameter/${var.project_name}/*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = [
          "arn:aws:secretsmanager:${var.aws_region}:${var.aws_account_id}:secret:*"
        ]
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:ListSecrets"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "nginx_ssm" {
  role       = aws_iam_role.nginx.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_instance_profile" "nginx" {
  name = "${var.project_name}-nginx-profile"
  role = aws_iam_role.nginx.name
  tags = var.common_tags
}

resource "aws_instance" "nginx" {
  ami           = data.aws_ami.amazon_linux.id
  instance_type = var.instance_type
  subnet_id     = var.public_subnet_ids[0]

  iam_instance_profile   = aws_iam_instance_profile.nginx.name
  vpc_security_group_ids = [aws_security_group.nginx.id]
  associate_public_ip_address = true

  user_data = templatefile("${path.root}/scripts/nginx-user-data.sh", {
    project_name      = var.project_name
    health_check_script = file("${path.root}/scripts/health-check.sh")
  })

  root_block_device {
    volume_type = "gp3"
    volume_size = 30
    encrypted   = true
    tags        = var.common_tags
  }

  tags = merge(var.common_tags, {
    Name = "${var.project_name}-nginx"
  })
}
