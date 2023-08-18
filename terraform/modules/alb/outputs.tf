output "target_group_id_pub" {
    value = aws_lb_target_group.tg-pub.id
}

output "target_group_id_private" {
    value = aws_lb_target_group.tg-priv.id
}