resource "aws_key_pair" "client_key" {
    key_name = "client_key_terraform_project"
    public_key = file("../modules/key/client_key.pub")
}