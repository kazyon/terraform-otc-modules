resource "openstack_lb_loadbalancer_v2" "loadbalancer" {
  name           = "${var.name}-loadbalancer"
  vip_subnet_id  = "${var.subnet_id}"
  admin_state_up = "true"
}

resource "openstack_lb_listener_v2" "listener" {
  name             = "${var.name}-listener"
  protocol         = "${var.protocol}"
  protocol_port    = "${var.listener_port}"
  loadbalancer_id  = "${openstack_lb_loadbalancer_v2.loadbalancer.id}"
  admin_state_up   = "true"
  connection_limit = "-1"
}

resource "openstack_lb_pool_v2" "pool" {
  protocol    = "${var.protocol}"
  lb_method   = "ROUND_ROBIN"
  listener_id = "${openstack_lb_listener_v2.listener.id}"
}

resource "openstack_lb_member_v2" "member" {
  count         = "${length(var.members)}"
  address       = "${element(var.members, count.index)}"
  pool_id       = "${openstack_lb_pool_v2.pool.id}"
  subnet_id     = "${var.subnet_id}"
  protocol_port = "${var.member_port}"
}

resource "openstack_lb_monitor_v2" "monitor" {
  pool_id        = "${openstack_lb_pool_v2.pool.id}"
  type           = "${var.protocol}"
  url_path       = "${var.monitor_url_path}"
  expected_codes = "${var.monitor_expected_codes}"
  delay          = "${var.monitor_delay}"
  timeout        = "${var.monitor_timeout}"
  max_retries    = "${var.monitor_retries}"
}
