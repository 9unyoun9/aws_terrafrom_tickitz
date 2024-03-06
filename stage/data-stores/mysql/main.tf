provider "aws" {
  region = "ap-northeast-2"

  # 2.x 버전의 AWS 공급자 허용
  version = "~> 2.0"
}

terraform {
  backend "s3" {
    # This backend configuration is filled in automatically at test time by Terratest. If you wish to run this example
    # manually, uncomment and fill in the config below.

    bucket         = "terraform-s3-9unyun9"
    key            = "stage/terraform.tfstage" # 이 부분을 다르게 stage/ prod/
    region         = "ap-northeast-2"
    dynamodb_table = "terraform-dynamo-9unyun9"
    encrypt        = true
  }
}

resource "aws_db_instance" "example" {
  identifier_prefix   = "terraform-up-and-running"
  engine              = "mysql"
  allocated_storage   = 10
  instance_class      = "db.t2.micro"
  name                = var.db_name
  username            = "admin"
  skip_final_snapshot = true
  password            = jsondecode(data.aws_secretsmanager_secret_version.db_password.secret_string) ["password"] # 비밀번호 가져오기
}

data "aws_secretsmanager_secret_version" "db_password" { # AWS Secrets Manager에서 비밀번호 가져오기
  secret_id     = "9unyun9_key" # 보안 암호 이름
}