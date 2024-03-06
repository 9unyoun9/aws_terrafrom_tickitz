# # ec2 이미지 id 최신 버전 가져오기
# data "aws_ami" "latest_amazon_linux" {
#   most_recent = true

#   filter {
#     name   = "name"
#     values = ["amzn2-ami-hvm-2.0.????????-x86_64-gp2"]
#   }

#   filter {
#     name   = "virtualization-type"
#     values = ["hvm"]
#   }

#   owners = ["amazon"]
# }

# # 시작 구성 관련
# resource "aws_launch_configuration" "example" {
#   image_id        = data.aws_ami.latest_amazon_linux.id
#   instance_type   = var.instance_type
#   security_groups = [aws_security_group.instance.id] ## atribute 속성 참조 맨 밑 하단 기술문서
#   user_data       = data.template_file.user_data.rendered
#   # rendered : 렌더링된 템플릿을 반환합니다. 이 속성은 템플릿 파일을 렌더링하고 변수를 채워넣습니다.
#   # 
#   key_name        = "Cloud-AWS"

#   # 오토스케일링 그룹과 함께 시작 구성을 사용할 때 필요합니다.
#   # https://www.terraform.io/docs/providers/aws/r/launch_configuration.html
#   lifecycle {
#     create_before_destroy = true
#   }
# }

data "template_file" "user_data" {
  template = file("${path.module}/user-data.sh") # ${path.module} : 현재 모듈의 경로를 반환합니다. = 루트모듈에서 호출되어지는 상대경로와 같음 ex = ../../../modules/services/webserver-cluster

  vars = {
    server_port = var.server_port
    db_address  = data.terraform_remote_state.db.outputs.address
    db_port     = data.terraform_remote_state.db.outputs.port
  }
}

resource "aws_autoscaling_group" "example" {
  launch_configuration = aws_launch_configuration.example.name
  vpc_zone_identifier  = data.aws_subnet_ids.default.ids
  target_group_arns    = [aws_lb_target_group.asg.arn]
  health_check_type    = "ELB"

  min_size = var.min_size # 이 경우 루트 모듈에서 호출되어지는 변수를 사용하게 됨
  max_size = var.max_size

  tag {
    key                 = "Name"
    value               = var.cluster_name # 이 경우 루트 모듈에서 호출되어지는 변수를 사용하게 됨
    propagate_at_launch = true  # 태그가 루트모듈에서 설정한 이름으로 자동으로 생성됨
  }
}

# 인스턴스 보안그룹
# 보안그룹 관련 리소스가 분리되어 있어서 보안블럭이 삭제되고 생성되어도 보안그룹이 삭제되지 않음
resource "aws_security_group" "instance" {
  name = "${var.cluster_name}-instance"
}

# 인스턴스 보안그룹규칙 - http
resource "aws_security_group_rule" "allow_server_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port   = var.server_port
  to_port     = var.server_port
  protocol    = local.tcp_protocol # 지역 변수
  cidr_blocks = local.all_ips
}

# 인스턴스 보안그룹규칙 - egress
resource "aws_security_group_rule" "allow_server_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.instance.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol # 지역 변수
  cidr_blocks = local.all_ips
}

# 인스턴스 보안그룹규칙 - ssh
resource "aws_security_group_rule" "allow_server_ssh_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.instance.id

  from_port   = var.server_ssh_port
  to_port     = var.server_ssh_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

resource "aws_lb" "example" {
  name               = var.cluster_name
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.default.ids
  security_groups    = [aws_security_group.alb.id]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port              = local.http_port
  protocol          = "HTTP"

  # By default, return a simple 404 page
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code  = 404
    }
  }
}

resource "aws_lb_target_group" "asg" {
  name     = var.cluster_name
  port     = var.server_port
  protocol = "HTTP"
  vpc_id   = data.aws_vpc.default.id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 15
    timeout             = 3
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority     = 100

  condition {
    path_pattern { # 경로 패턴
      values = ["*"] # 모든 경로
    }
  }

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}

resource "aws_security_group" "alb" {
  name = "${var.cluster_name}-alb"
}

resource "aws_security_group_rule" "allow_http_inbound" {
  type              = "ingress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.http_port
  to_port     = local.http_port
  protocol    = local.tcp_protocol
  cidr_blocks = local.all_ips
}

resource "aws_security_group_rule" "allow_all_outbound" {
  type              = "egress"
  security_group_id = aws_security_group.alb.id

  from_port   = local.any_port
  to_port     = local.any_port
  protocol    = local.any_protocol
  cidr_blocks = local.all_ips
}

data "terraform_remote_state" "db" {
  backend = "s3"

  config = {
    bucket = var.db_remote_state_bucket # 루트모듈에서 값을 지정하지 않았다면 일반 모듈에서 정한 값으로 가져옴
    key    = var.db_remote_state_key # 루트모듈에서 값이 우선 적용
    region = "ap-northeast-2"
  }
}

locals {
  http_port    = 80
  any_port     = 0
  any_protocol = "-1"
  tcp_protocol = "tcp"
  all_ips      = ["0.0.0.0/0"]
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnet_ids" "default" {
  vpc_id = data.aws_vpc.default.id
}

