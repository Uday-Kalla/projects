resource "aws_security_group" "lambda_sg" {
  name        = "${var.project_name}-sg"
  description = "Lambda security group"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "sg_id" {
  value = aws_security_group.lambda_sg.id
}
