output "security_groups" {
  value      = data.aws_security_groups.test.ids
  depends_on = [data.aws_security_groups.test]
}