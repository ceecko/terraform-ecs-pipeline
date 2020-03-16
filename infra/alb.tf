resource "aws_alb" "main" {
  name            = "cb-load-balancer"
  subnets         = ["${aws_default_subnet.default_eu_west_1a.id}", "${aws_default_subnet.default_eu_west_1b.id}"]
  security_groups = ["${aws_security_group.misfits_lb.id}"]
}

resource "aws_alb_target_group" "app" {
  name                 = "cb-target-group"
  port                 = 80
  protocol             = "HTTP"
  vpc_id               = "${aws_default_vpc.default.id}"
  target_type          = "ip"
  deregistration_delay = 30

  health_check {
    healthy_threshold   = "3"
    interval            = "30"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
}

resource "aws_alb_listener" "front_end" {
  load_balancer_arn = "${aws_alb.main.id}"
  port              = "80"
  protocol          = "HTTP"

  default_action {
    target_group_arn = "${aws_alb_target_group.app.id}"
    type             = "forward"
  }
}