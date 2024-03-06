provider "aws" {
  region = "ap-northeast-2"

  # 2.x 버전의 AWS 공급자 허용
  version = "~> 2.0"
}

module "webserver_cluster" {
  source = "../../../modules/services/webserver-cluster"

  cluster_name           = var.cluster_name
  db_remote_state_bucket = var.db_remote_state_bucket
  db_remote_state_key    = var.db_remote_state_key

  instance_type = "m4.large" # 실제 상대들을 대응하기 위해 높은 사양으로 설정
  min_size      = 2
  max_size      = 10
}

## 동적 조정정책 스케줄링
## EC2인스턴스의 웹접속 트래픽이 많은 낮시간에는 인스턴스를 늘리고, 트래픽이 적은 밤시간에는 인스턴스를 줄이는 것이 좋다.
## 
# resource "aws_autoscaling_schedule" "scale_out_during_business_hours" {
#   scheduled_action_name = "scale-out-during-business-hours"
#   min_size              = 2
#   max_size              = 10
#   desired_capacity      = 10
#   recurrence            = "0 9 * * *"

#   autoscaling_group_name = module.webserver_cluster.asg_name # 모듈 출력
#   # 오토스케일링 그룹에 들어가야 함
#   # 오토스케일링 그룹은 일반모듈에서 생성하는데
#   # 일반 모듈에서 생성한 리소스를 참조하는 것은 모듈에서 생성한 리소스를 참조하는 것과 동일하다.
#   # 모듈 출력변수 == module.webserver_cluster
#   # 일반 모듈의 속성값을 빼낼 때 사용 할 수 있음

# }

# resource "aws_autoscaling_schedule" "scale_in_at_night" {
#   scheduled_action_name = "scale-in-at-night"
#   min_size              = 2
#   max_size              = 10
#   desired_capacity      = 2
#   recurrence            = "0 17 * * *"

#   autoscaling_group_name = module.webserver_cluster.asg_name
# }

##############################################
# 조건문 0123
##############################################
