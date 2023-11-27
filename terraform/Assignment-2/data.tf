data "aws_instances" "test-instances" {
  filter {
    name   = "instance.group-id"
    values = [aws_security_group.test-sg.id]
  }

  instance_state_names = ["running"]
}
