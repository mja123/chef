variable "public_key" {
  description = "Public key associated with ec2 intances"
  type        = string
  sensitive   = true
}

variable "private_key_path" {
  description = "Path to store private key"
  type        = string
}