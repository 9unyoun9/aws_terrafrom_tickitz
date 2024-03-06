provider "aws" {
  region = "ap-northeast-2"

  # 2.x 버전의 AWS 공급자 허용
  version = "~> 2.0"
}

# 모델 호출의 기본 코드
module "webserver_cluster" { # 모듈 호출 모듈의 로지컬 ID
  source = "../../../modules/services/webserver-cluster" # 모듈의 상대 경로 # 첫 행에 무조건 있어야 함 # 참조할 일반 모듈 경로 
  # 테라폼의 모든 경로는 상대 경로
  # ../../../modules/services/webserver-cluster 상대경로로 쓴 폴더 안에 파일들이 다 쓰이게 됨
  # 소스를 두개 쓰일 수 없어서 두개의 모듈을 쓰려면 모듈블럭을 또 생성해야 함

  # 모듈의 변수에 값을 넣어줌
  # 좌변} 사용자 지정 매개변수 => (소스의 variables.tf에 있는 변수들)
  ## 좌변의 변수에 서비스 관련 값을 다 넣어줘서 root 모듈에 변수만 매칭하면 됨
  # 우변} root모듈에서 지정한  => (root모듈의 variables.tf에 있는 변수들, 값)
  ## root모듈은 변수값 default를 지정하면 안됨(소스파일에 지정 해놨기 때문6)
  cluster_name           = var.cluster_name
  db_remote_state_bucket = var.db_remote_state_bucket
  db_remote_state_key    = var.db_remote_state_key
  # 일반 모듈쪽 입력 매개 변수 = 

  # root 모듈에서 입력변수값을 변경하면 root모듈이 우선으로 값을 가져온다

  instance_type = "t2.micro"
  min_size      = 2 # 일반모듈에서 min_size = var.min_size로 쓰임
  max_size      = 2
}

resource "aws_security_group_rule" "allow_testing_inbound" {
  type              = "ingress"
  security_group_id = module.webserver_cluster.instance_security_group_id

  from_port   = 8080
  to_port     = 8080
  protocol    = "tcp"
  cidr_blocks = ["0.0.0.0/0"]
}

