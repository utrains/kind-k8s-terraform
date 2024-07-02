# configured aws provider with proper credentials
provider "aws" {
  region    = var.aws_region
  profile   = var.profile
}

# create default vpc if one does not exit
resource "aws_default_vpc" "default_vpc" {
}

# use data source to get all avalablility zones in region
data "aws_availability_zones" "available_zones" {}


resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  tags   = {
    Name = "utrains default subnet"
  }
}

resource "aws_security_group" "kind_security_group" {
  name        = "kind security group"
  description = "allow access on ports 8080 and 22"
  vpc_id      = aws_default_vpc.default_vpc.id

  ingress {
    description      = "http proxy access"
    from_port        = 8080
    to_port          = 8080
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }
  # allow access on port 22 ssh connection
  ingress {
    description      = "ssh access"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = -1
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags   = {
    Name = "utrains jenkins server security group"
  }
}

resource "aws_instance" "ec2_instance" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.aws_instance_type
  subnet_id              = aws_default_subnet.default_az1.id
  vpc_security_group_ids = [aws_security_group.kind_security_group.id]
  key_name               = aws_key_pair.jenkins_key.key_name
  user_data            = file("installkind.sh")


  tags = {
    Name = "kind-k8s-server"
  }
}

resource "null_resource" "example_provisioner" {
  triggers = {
    public_ip = aws_instance.ec2_instance.public_ip
  }

 connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(local_file.ssh_key.filename)
    host        = aws_instance.ec2_instance.public_ip
  }

  // copy our example script to the server
  provisioner "file" {
    source      = "./installkind.sh"
    destination = "/tmp/installkind.sh"
  }

  // change permissions to executable and pipe its output into a new file
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/installkind.sh",
      "sh /tmp/installkind.sh",
    ]
  }

  depends_on = [aws_instance.ec2_instance]
}

# resource "null_resource" "name" {

#   # ssh into the ec2 instance 
#   connection {
#     type        = "ssh"
#     user        = "ubuntu"
#     private_key = file(local_file.ssh_key.filename)
#     host        = aws_instance.ec2_instance.public_ip
#   }


#   # set permissions and run the  file
#   provisioner "remote-exec" {
#     inline = [
#       "sudo apt update",
#       "sudo apt-get install docker.io -y",
#       "sudo usermod -aG docker ubuntu",
#       "sudo chmod 666 /var/run/docker.sock",
#       "curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.14.0/kind-linux-amd64",
#       "chmod +x ./kind",
#       "sudo mv ./kind /usr/bin/kind",
#       "curl -LO https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl",
#       "chmod +x ./kubectl",
#       "sudo mv ./kubectl /usr/bin/kubectl",





#       # download the latest version of nexus
#       "sudo wget https://download.sonatype.com/nexus/3/nexus-3.45.0-01-unix.tar.gz",

#       "sudo yum upgrade -y",
#       # Extract the downloaded archive file
#       "tar -xvzf nexus-3.45.0-01-unix.tar.gz",
#       "rm -f nexus-3.45.0-01-unix.tar.gz",
#       "sudo mv nexus-3.45.0-01 nexus",

#       # Start Nexus and check status
#       "sh ~/nexus/bin/nexus start",
#       "sh ~/nexus/bin/nexus status",
#         ]
#   }

#   # wait for ec2 to be created
#   depends_on = [aws_instance.ec2_instance]
# }
