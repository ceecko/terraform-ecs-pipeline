data "aws_iam_policy" "ecs_task_execution" {
  arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role" "misfits_ecs" {
  name = "misfits_ecs_task_execution"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "ecs-tasks.amazonaws.com"
      },
      "Action": "sts:AssumeRole"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy_attach" {
  role = "${aws_iam_role.misfits_ecs.name}"
  # required due to awslogs
  policy_arn = "${data.aws_iam_policy.ecs_task_execution.arn}"
}

resource "aws_ecs_task_definition" "misfits" {
  family                   = "misfits"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  container_definitions    = "${file("./task-definitions/misfits.json")}"
  execution_role_arn       = "${aws_iam_role.misfits_ecs.arn}"
}

resource "aws_ecs_service" "misfits" {
  name            = "misfits"
  cluster         = "${aws_ecs_cluster.misfits.id}"
  task_definition = "${aws_ecs_task_definition.misfits.family}"
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = ["${aws_default_subnet.default_eu_west_1a.id}", "${aws_default_subnet.default_eu_west_1b.id}"]
    security_groups  = ["${aws_security_group.ecs_tasks.id}"]
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = "${aws_alb_target_group.app.id}"
    container_name   = "misfits"
    container_port   = 80
  }

  depends_on = [aws_alb_listener.front_end, aws_iam_role_policy_attachment.ecs_task_execution_role_policy_attach]
}

resource "aws_ecs_cluster" "misfits" {
  name               = "misfits"
  capacity_providers = ["FARGATE"]
}

