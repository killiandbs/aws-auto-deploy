terraform {
        required_providers {
                aws = {
                        source  = "hashicorp/aws"
                }
        }
}
provider "aws" {
        region = "eu-west-3"
}
resource "aws_vpc" "testgitinfra3-VPC" {
        cidr_block = "10.0.0.0/16"
        tags = {
                Name = "testgitinfra3-VPC"
        }
}
resource "aws_subnet" "testgitinfra3-SUBNET-PUBLIC" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        cidr_block = "10.0.1.0/24"
        tags = {
                Name = "testgitinfra3-SUBNET-PUBLIC"
        }
}
resource "aws_subnet" "testgitinfra3-SUBNET-AZ-A" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        cidr_block = "10.0.2.0/24"
        availability_zone = "eu-west-3a"
        tags = {
                Name = "testgitinfra3-SUBNET-AZ-A"
        }
}
resource "aws_subnet" "testgitinfra3-SUBNET-AZ-B" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        cidr_block = "10.0.3.0/24"
        availability_zone = "eu-west-3b"
        tags = {
                Name = "testgitinfra3-SUBNET-AZ-B"
        }
}
resource "aws_subnet" "testgitinfra3-SUBNET-AZ-C" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        cidr_block = "10.0.4.0/24"
        availability_zone = "eu-west-3c"
        tags = {
                Name = "testgitinfra3-SUBNET-AZ-C"
        }
}
resource "aws_internet_gateway" "testgitinfra3-IGW" {
        tags = {
                Name = "testgitinfra3-IGW"
        }
}
resource "aws_internet_gateway_attachment" "testgitinfra3-IGW-ATTACH" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        internet_gateway_id = "${aws_internet_gateway.testgitinfra3-IGW.id}"
}
resource "aws_route_table" "testgitinfra3-RTB-PUBLIC" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        route {
                cidr_block = "0.0.0.0/0"
                gateway_id = "${aws_internet_gateway.testgitinfra3-IGW.id}"
        }
        tags = {
                Name = "testgitinfra3-RTB-PUBLIC"
        }
}
resource "aws_route_table_association" "testgitinfra3-RTB-PUBLIC-ASSOC1" {
        subnet_id = "${aws_subnet.testgitinfra3-SUBNET-AZ-A.id}"
        route_table_id = "${aws_route_table.testgitinfra3-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "testgitinfra3-RTB-PUBLIC-ASSOC2" {
        subnet_id = "${aws_subnet.testgitinfra3-SUBNET-AZ-B.id}"
        route_table_id = "${aws_route_table.testgitinfra3-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "testgitinfra3-RTB-PUBLIC-ASSOC3" {
        subnet_id = "${aws_subnet.testgitinfra3-SUBNET-AZ-C.id}"
        route_table_id = "${aws_route_table.testgitinfra3-RTB-PUBLIC.id}"
}
resource "aws_route_table_association" "testgitinfra3-RTB-PUBLIC-ASSOC" {
        subnet_id = "${aws_subnet.testgitinfra3-SUBNET-PUBLIC.id}"
        route_table_id = "${aws_route_table.testgitinfra3-RTB-PUBLIC.id}"
}
resource "aws_security_group" "testgitinfra3-SG-PUBLIC" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = "3128"
                to_port = "3128"
                protocol = "tcp"
                security_groups = ["${aws_security_group.testgitinfra3-SG-WEB.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "testgitinfra3-SG-PUBLIC"
        }
}
resource "aws_security_group" "testgitinfra3-SG-LOAD-BALANCER" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "testgitinfra3-SG-LOAD-BALANCER"
        }
}
resource "aws_security_group" "testgitinfra3-SG-WEB" {
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        ingress {
                from_port = "22"
                to_port = "22"
                protocol = "tcp"
                cidr_blocks = ["0.0.0.0/0"]
        }
        ingress {
                from_port = "80"
                to_port = "80"
                protocol = "tcp"
                security_groups = ["${aws_security_group.testgitinfra3-SG-LOAD-BALANCER.id}"]
        }
        egress {
                from_port = "0"
                to_port = "0"
                protocol = "-1"
                cidr_blocks = ["0.0.0.0/0"]
        }
        tags = {
                Name = "testgitinfra3-SG-PUBLIC"
        }
}
resource "aws_instance" "testgitinfra3-INSTANCE-PUBLIC" {
        subnet_id = "${aws_subnet.testgitinfra3-SUBNET-PUBLIC.id}"
        instance_type = "t2.micro"
        ami = "ami-091b37bfd6e01db4f"
        key_name = "COLIN-KEYPAIR"
        vpc_security_group_ids = ["${aws_security_group.testgitinfra3-SG-PUBLIC.id}"]
        associate_public_ip_address = true
        user_data = file("squid.sh")
        tags = {
                Name = "testgitinfra3-INSTANCE-PUBLIC"
        }
}
resource "aws_instance" "testgitinfra3-INSTANCE-AZ-A" {
        subnet_id = "${aws_subnet.testgitinfra3-SUBNET-AZ-A.id}"
        instance_type = "t2.micro"
        ami = "ami-091b37bfd6e01db4f"
        key_name = "COLIN-KEYPAIR"
        vpc_security_group_ids = ["${aws_security_group.testgitinfra3-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.testgitinfra3-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "testgitinfra3-INSTANCE-AZ-A"
        }
}
resource "aws_instance" "testgitinfra3-INSTANCE-AZ-B" {
        subnet_id = "${aws_subnet.testgitinfra3-SUBNET-AZ-B.id}"
        instance_type = "t2.micro"
        ami = "ami-091b37bfd6e01db4f"
        key_name = "COLIN-KEYPAIR"
        vpc_security_group_ids = ["${aws_security_group.testgitinfra3-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.testgitinfra3-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "testgitinfra3-INSTANCE-AZ-B"
        }
}
resource "aws_instance" "testgitinfra3-INSTANCE-AZ-C" {
        subnet_id = "${aws_subnet.testgitinfra3-SUBNET-AZ-C.id}"
        instance_type = "t2.micro"
        ami = "ami-091b37bfd6e01db4f"
        key_name = "COLIN-KEYPAIR"
        vpc_security_group_ids = ["${aws_security_group.testgitinfra3-SG-WEB.id}"]
        associate_public_ip_address = false
        user_data = "${templatefile("web.sh", { SQUID_IP = "${aws_instance.testgitinfra3-INSTANCE-PUBLIC.private_ip}" })}"
        tags = {
                Name = "testgitinfra3-INSTANCE-AZ-C"
        }
}
resource "aws_lb" "testgitinfra3-LB" {
        name = "testgitinfra3-LB"
        subnets = ["${aws_subnet.testgitinfra3-SUBNET-AZ-A.id}", "${aws_subnet.testgitinfra3-SUBNET-AZ-B.id}", "${aws_subnet.testgitinfra3-SUBNET-AZ-C.id}"]
        security_groups = ["${aws_security_group.testgitinfra3-SG-LOAD-BALANCER.id}"]
}
resource "aws_lb_target_group" "testgitinfra3-LB-TG2" {
        name = "testgitinfra3-LB-TG2"
        port = 80
        protocol = "HTTP"
        vpc_id = "${aws_vpc.testgitinfra3-VPC.id}"
        target_type = "instance"
}
resource "aws_lb_target_group_attachment" "testgitinfra3-LB-TG2-ATTACH-1" {
        target_group_arn = "${aws_lb_target_group.testgitinfra3-LB-TG2.arn}"
        target_id = "${aws_instance.testgitinfra3-INSTANCE-AZ-A.id}"
        port = 80
}
resource "aws_lb_target_group_attachment" "testgitinfra3-LB-TG2-ATTACH-2" {
        target_group_arn = "${aws_lb_target_group.testgitinfra3-LB-TG2.arn}"
        target_id = "${aws_instance.testgitinfra3-INSTANCE-AZ-B.id}"
        port = 80
}
resource "aws_lb_target_group_attachment" "testgitinfra3-LB-TG2-ATTACH-3" {
        target_group_arn = "${aws_lb_target_group.testgitinfra3-LB-TG2.arn}"
        target_id = "${aws_instance.testgitinfra3-INSTANCE-AZ-C.id}"
        port = 80
}
resource "aws_lb_listener" "testgitinfra3-LB-LISTENER" {
        load_balancer_arn = "${aws_lb.testgitinfra3-LB.arn}"
        port = "80"
        protocol = "HTTP"
        default_action {
                type = "forward"
                target_group_arn = "${aws_lb_target_group.testgitinfra3-LB-TG2.arn}"
        }
}
