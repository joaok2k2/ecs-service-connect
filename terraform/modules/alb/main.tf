resource "aws_lb" "alb-pub" {
  name               = var.pub-alb-name
  internal           = false
  load_balancer_type = "application"
  security_groups    = var.sg-id
  subnets            = var.pub-sub

  enable_deletion_protection = true

  tags = {
    Environment = "DEV"
  }
}

resource "aws_lb" "private-alb" {
  name               = var.private-alb-name
  internal           = true
  load_balancer_type = "application"
  security_groups    = var.sg-id
  subnets            = var.private-sub

  enable_deletion_protection = true

  tags = {
    Environment = "DEV"
  }
}



resource "aws_lb_target_group" "tg-pub" {
  name        = var.name_target_group_pub
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
  depends_on = [aws_lb.alb-pub]
}

resource "aws_lb_listener" "pub-listener_80" {
  load_balancer_arn = aws_lb.alb-pub.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}


resource "aws_lb_listener" "pub-listener_443" {
  load_balancer_arn = aws_lb.alb-pub.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-sub.arn
  }
}

resource "aws_lb_target_group" "tg-priv" {
  name        = var.name_target_group_private
  port        = 80
  protocol    = "HTTP"
  target_type = "ip"
  vpc_id      = var.vpc_id

  health_check {
    healthy_threshold   = "3"
    interval            = "300"
    protocol            = "HTTP"
    matcher             = "200"
    timeout             = "3"
    path                = "/"
    unhealthy_threshold = "2"
  }
  depends_on = [aws_lb.private-alb]
}

resource "aws_lb_listener" "private-listener_80" {
  load_balancer_arn = aws_lb.private-alb.id
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "redirect"
    redirect {
      port        = "443"
      protocol    = "HTTPS"
      status_code = "HTTP_301"
    }
  }
}

resource "aws_lb_listener" "private-listener_443" {
  load_balancer_arn = aws_lb.alb-pub.id
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.certificate_arn

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.tg-priv.arn
  }
}
