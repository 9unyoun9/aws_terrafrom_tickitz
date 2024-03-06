# VPC 모듈 설정
resource "aws_vpc" "titlevpc" {
  cidr_block           = var.vpc_cidr_block # default "10.0.0.0/16"
  enable_dns_hostnames = true # DNS 호스트 이름을 활성화하면 인스턴스에 대한 퍼블릭 DNS 호스트 이름이 자동으로 생성
  enable_dns_support   = true # DNS 지원을 활성화하면 인스턴스에 대한 DNS 서버 주소가 자동으로 할당
  instance_tenancy     = "default" # 인스턴스 테넌시를 지정합니다. 기본값은 default입니다. 이 값은 dedicated 또는 host로 설정할 수 있습니다.
  
  tags = {
    Name = var.title_name + "-Vpc"
  }
}


# VPC 호출할 때
# module "vpc" {
#   source = "./modules/vpc"
# }

# data 가져오기
data "aws_availability_zones" "available" {}

  # ${var.title_name}
############### Subnet, RouteTable, IGW ###############

  ###### 컨테이너 관련 설정 ######
  ## 컨테이너 애플리케이션용 프라이빗 서브넷
resource "aws_subnet" "titleSubnetPrivateContainer1A" {
  cidr_block        = var.SubnetPrivateContainer1A_cidr_block # default "10.0.8.0/24"
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title_name}-subnet-private-container-1a"
    Type = "Isolated"
  }
}
resource "aws_subnet" "titleSubnetPrivateContainer1C" {
  cidr_block        = var.SubnetPrivateContainer1C_cidr_block # default "10.0.8.0/24"
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title_name}-subnet-private-container-1c"
    Type = "Isolated"
  }
}

  ## 컨테이너 애플리케이션용 라우팅 테이블
resource "aws_route_table" "titleRouteApp" {
  vpc_id = aws_vpc.titlevpc.id

  tags = {
    Name = "${var.title_name}-route-app"
  }
}

  ## 컨테이너 서브넷과 라우팅 연결
resource "aws_route_table_association" "titleRouteAppAssociation1A" {
  subnet_id      = aws_subnet.titleSubnetPrivateContainer1A.id
  route_table_id = aws_route_table.titleRouteApp.id
}

resource "aws_route_table_association" "titleRouteAppAssociation1C" {
  subnet_id      = aws_subnet.titleSubnetPrivateContainer1C.id
  route_table_id = aws_route_table.titleRouteApp.id
}

  ####### DB관련 설정 ########
  ## DB용 프라이빗 서브넷
resource "aws_subnet" "titleSubnetPrivateDb1A" {
  cidr_block        = var.SubnetPrivateDb1A_cidr_block
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title_name}-subnet-private-db-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "titleSubnetPrivateDb1C" {
  cidr_block        = var.SubnetPrivateDb1C_cidr_block
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title_name}-subnet-private-db-1c"
    Type = "Isolated"
  }
}

  ## DB용 라우팅 테이블
resource "aws_route_table" "titleRouteDb" {
  vpc_id = aws_vpc.titlevpc.id

  tags = {
    Name = "${var.title_name}-route-db"
  }
}

  ## DB 서브넷에 라우팅 연결
resource "aws_route_table_association" "titleRouteDbAssociation1A" {
  subnet_id      = aws_subnet.titleSubnetPrivateDb1A.id
  route_table_id = aws_route_table.titleRouteDb.id
}

resource "aws_route_table_association" "titleRouteDbAssociation1C" {
  subnet_id      = aws_subnet.titleSubnetPrivateDb1C.id
  route_table_id = aws_route_table.titleRouteDb.id
}

  ######## Ingress 관련 설정 ########
  ## Ingress용 퍼블릭 서브넷
resource "aws_subnet" "titleSubnetPublicIngress1A" {
  cidr_block        = var.SubnetPublicIngress1A_cidr_block
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title_name}-subnet-public-ingress-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "titleSubnetPublicIngress1C" {
  cidr_block        = var.SubnetPublicIngress1C_cidr_block
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title_name}-subnet-public-ingress-1c"
    Type = "Public"
  }
}

  ## Ingress용 라우팅 테이블
resource "aws_route_table" "titleRouteIngress" {
  vpc_id = aws_vpc.titlevpc.id

  tags = {
    Name = "${var.title_name}-route-ingress"
  }
}

  ## Ingress용 서브넷에 라우팅 연결
resource "aws_route_table_association" "titleRouteIngressAssociation1A" {
  subnet_id      = aws_subnet.titleSubnetPublicIngress1A.id
  route_table_id = aws_route_table.titleRouteIngress.id
}

resource "aws_route_table_association" "titleRouteIngressAssociation1C" {
  subnet_id      = aws_subnet.titleSubnetPublicIngress1C.id
  route_table_id = aws_route_table.titleRouteIngress.id
}

  ## Ingress용 라우팅 테이블의 기본 라우팅
resource "aws_route" "titleRouteIngressDefault" {
  route_table_id         = aws_route_table.titleRouteIngress.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.titleIgw.id
  depends_on = [aws_vpc_gateway_attachment.titleVpcgwAttachment]
}


  ######## 관리 서버 관련 설정 ########
  ## 관리용 퍼블릭 서브넷
resource "aws_subnet" "titleSubnetPublicManagement1A" {
  cidr_block        = var.SubnetPublicManagement1A_cidr_block # "10.0.240.0/24"
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title_name}-subnet-public-management-1a"
    Type = "Public"
  }
}

resource "aws_subnet" "titleSubnetPublicManagement1C" {
  cidr_block        = var.SubnetPublicManagement1C_cidr_block # "10.0.241.0/24"
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.title_name}-subnet-public-management-1c"
    Type = "Public"
  }
}

  ## 관리용 서브넷의 라우팅은 Ingress와 동일하게 생성
resource "aws_route_table_association" "titleRouteManagementAssociation1A" {
  subnet_id      = aws_subnet.titleSubnetPublicManagement1A.id
  route_table_id = aws_route_table.titleRouteIngress.id
}

resource "aws_route_table_association" "titleRouteManagementAssociation1C" {
  subnet_id      = aws_subnet.titleSubnetPublicManagement1C.id
  route_table_id = aws_route_table.titleRouteIngress.id
}


  ######## 인터넷 접속을 위한 게이트웨이 생성 ########
resource "aws_vpn_gateway" "titlevgw" {
  tags = {
    Name = "${var.title_name}-igw"
  }
}

resource "aws_vpn_gateway_attachment" "titleVpcgwAttachment" {
  vpc_id          = aws_vpc.titlevpc.id
  vpn_gateway_id  = aws_vpn_gateway.titlevgw.id
}


  ######## VPC 엔드포인트 관련 설정 ########
  ## VPC 엔드포인트(Egress통신)용 프라이빗 서브넷
resource "aws_subnet" "titleSubnetPrivateEgress1A" {
  cidr_block        = var.SubnetPrivateEgress1A_cidr_block #"10.0.248.0/24"
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[0]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title_name}-subnet-private-egress-1a"
    Type = "Isolated"
  }
}

resource "aws_subnet" "titleSubnetPrivateEgress1C" {
  cidr_block        = var.SubnetPrivateEgress1C_cidr_block #"10.0.249.0/24"
  vpc_id            = aws_vpc.titlevpc.id
  availability_zone = data.aws_availability_zones.available.names[1]
  map_public_ip_on_launch = false

  tags = {
    Name = "${var.title_name}-subnet-private-egress-1c"
    Type = "Isolated"
  }
}


  ############### Security groups ###############
  # 보안 그룹 생성
  ## 인터넷 공개용 보안 그룹 생성
resource "aws_security_group" "titleSgIngress" {
  description = "Security group for ingress"
  name        = "internet-ingress" 
  vpc_id      = aws_vpc.titlevpc.id

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "from 0.0.0.0/0:80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "from ::/0:80"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "${var.title_name}-sg-internet-ingress"
  }
}

  ## 관리 서버용 보안 그룹 생성
resource "aws_security_group" "titleSgManagement" {
  description = "Security Group of management server"
  name        = "server-management" 
  vpc_id      = aws_vpc.titlevpc.id

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.title_name}-sg-server-management"
  }
}

  ## 백엔드 컨테이너 애플리케이션용 보안 그룹 생성
resource "aws_security_group" "titleSgBackContainer" {
  description = "Security Group of management server"
  name        = "be-container-management"
  vpc_id      = aws_vpc.titlevpc.id

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.title_name}-sg-be-container"
  }
}

  ## 프론트엔드 컨테이너 애플리케이션용 보안 그룹 생성
resource "aws_security_group" "titleSgFrontContainer" {
  description = "Security Group of front container app"
  name        = "front-container-management"
  vpc_id      = aws_vpc.titlevpc.id

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.title_name}-sg-front-container"
  }
}

  ## 내부용 로드밸런서의 보안 그룹 생성
resource "aws_security_group" "titleSgInternal" {
  description = "Security group for internal load balancer"
  name        = "internal-lb"
  vpc_id      = aws_vpc.titlevpc.id

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.title_name}-sg-internal-lb"
  }
}

  ## DB용 보안 그룹 생성
resource "aws_security_group" "titleSgDb" {
  description = "Security Group of database"
  name        = "sg-database"
  vpc_id      = aws_vpc.titlevpc.id

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.title_name}-sg-db"
  }
}

  ## VPC 엔드포인트용 보안 그룹 설정
resource "aws_security_group" "titleSgEgress" {
  description = "Security Group of VPC Endpoint"
  name        = "vpc-endpoint"
  vpc_id      = aws_vpc.titlevpc.id

  egress {
    description = "Allow all outbound traffic by default"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.title_name}-sg-vpcendpoint"
  }
}



  ############### 역할 연결 ###############
  ## Internet LB -> Front Container
resource "aws_security_group_rule" "titleSgFrontContainerFromSgIngress" {
  type              = "ingress"
  description       = "HTTP for Ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgFrontContainer.id

  source_security_group_id = aws_security_group.titleSgIngress.id
}

  ## Front Container -> Internal LB
resource "aws_security_group_rule" "titleSgInternalFromSgFrontContainer" {
  type              = "ingress"
  description       = "HTTP for front container"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgInternal.id

  source_security_group_id = aws_security_group.titleSgFrontContainer.id
}

  ## Internal LB -> Back Container
resource "aws_security_group_rule" "titleSgContainerFromSgInternal" {
  type              = "ingress"
  description       = "HTTP for internal lb"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgBackContainer.id

  source_security_group_id = aws_security_group.titleSgInternal.id
}

  ## Back container -> DB
resource "aws_security_group_rule" "titleSgDbFromSgContainerTCP" {
  type              = "ingress"
  description       = "PostgreSQL protocol from backend App"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgDb.id

  source_security_group_id = aws_security_group.titleSgBackContainer.id
}

  ## Front container -> DB
resource "aws_security_group_rule" "titleSgDbFromSgFrontContainerTCP" {
  type              = "ingress"
  description       = "PostgreSQL protocol from frontend App"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgDb.id

  source_security_group_id = aws_security_group.titleSgFrontContainer.id
}

  ## Management server -> DB
resource "aws_security_group_rule" "titleSgDbFromSgManagementTCP" {
  type              = "ingress"
  description       = "MySQL protocol from management server"
  from_port         = 5432
  to_port           = 5432
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgDb.id

  source_security_group_id = aws_security_group.titleSgManagement.id
}

  ## Management server -> Internal LB
resource "aws_security_group_rule" "titleSgManagementIngress" {
  type              = "ingress"
  description       = "HTTP for management server"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgInternal.id
  source_security_group_id = aws_security_group.titleSgManagement.id
}

  ## Back container -> VPC endpoint
resource "aws_security_group_rule" "titleSgContainerIngress" {
  type              = "ingress"
  description       = "HTTPS for Container App"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgEgress.id
  source_security_group_id = aws_security_group.titleSgBackContainer.id
}

  ## Front container -> VPC endpoint
resource "aws_security_group_rule" "titleSgFrontContainerIngress" {
  type              = "ingress"
  description       = "HTTPS for Front Container App"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgEgress.id
  source_security_group_id = aws_security_group.titleSgFrontContainer.id
}

  ## Management server -> VPC endpoint
resource "aws_security_group_rule" "titleSgManagementIngress" {
  type              = "ingress"
  description       = "HTTPS for management server"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.titleSgEgress.id
  source_security_group_id = aws_security_group.titleSgManagement.id
}


# sbcntr
# title
# ${var.title_name}





# data "template_file" "user_data" {
#   template = file("${path.module}/user-data.sh") # ${path.module} : 현재 모듈의 경로를 반환합니다. = 루트모듈에서 호출되어지는 상대경로와 같음 ex = ../../../modules/services/webserver-cluster

#   vars = {
#     server_port = var.server_port
#     db_address  = data.terraform_remote_state.db.outputs.address
#     db_port     = data.terraform_remote_state.db.outputs.port
#   }
# }



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

