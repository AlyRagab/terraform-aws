provider "aws" {
  access_key = "${var.aws_access_key}"
  secret_key = "${var.aws_secret_key}"
  region     = "${var.aws_region}"
}
resource "aws_instance" "myec2" {
  ami             = "${var.aws-ami}"
  instance_type   = "${var.instance_type}"
  key_name        = "${aws_key_pair.myec2key.key_name}"
  subnet_id       = "${aws_subnet.subnet.id}"
  vpc_security_group_ids = ["${aws_security_group.allow_ssh.id}"]
  root_block_device {
        volume_size = 40
    }
}
## Updating Security Group
resource "aws_security_group" "allow_ssh" {
  name        = "allow-ssh"
  description = "Allow SSH inbound traffic"
  vpc_id = "${aws_vpc.vpc.id}"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

## Create EC2 Key Pair
resource "aws_key_pair" "myec2key" {
  key_name = "publicKey"
  public_key = "${file(var.public_key_path)}"
}

## Create EBS Volume and Attach it
resource "aws_ebs_volume" "test-ebs" {
  availability_zone = "${var.availability_zone}"
  size              = "${var.volume-size}"
}resource "aws_volume_attachment" "test-ebs" {
  device_name = "/dev/sdh"
  volume_id   = "${aws_ebs_volume.test-ebs.id}"
  instance_id = "${aws_instance.myec2.id}"
}
