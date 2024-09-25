provider "aws" {
  region     = var.region
  access_key = var.aws_access_key
  secret_key = var.aws_secret_key
  token      = var.aws_session_token
}

# Identificando a VPC padrão
data "aws_vpc" "default" {
  default = true
}

# Criando o grupo de segurança
resource "aws_security_group" "main" {
  name = "containernet-group"
  vpc_id = data.aws_vpc.default.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Porta para acesso SSH"
  }

  ingress {
    from_port   = 8181
    to_port     = 8181
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Altere conforme necessário para restringir o acesso
    description = "Porta de interface do ONOS"
  }

  ingress {
    from_port   = 6653
    to_port     = 6653
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Altere conforme necessário para restringir o acesso
    description = "Uma das portas usadas pelo OpenFlow"
  }

  ingress {
    from_port   = 6633
    to_port     = 6633
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] # Altere conforme necessário para restringir o acesso
    description = "Uma das portas usadas pelo OpenFlow"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.security_group_name
  }
}

# Gerando par de chaves
resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Criando o par de chaves no AWS
resource "aws_key_pair" "main" {
  key_name   = var.key_name
  public_key = tls_private_key.main.public_key_openssh
}

# Salvando a chave privada localmente
resource "local_file" "private_key" {
  content  = tls_private_key.main.private_key_pem
  filename = "${path.module}/../../utils/credentials/keypair.pem"
}

# Criando a instância EC2
resource "aws_instance" "web" {
  ami                         = var.image
  instance_type               = "t2.large"
  key_name                    = aws_key_pair.main.key_name
  vpc_security_group_ids      = [aws_security_group.main.id]
  associate_public_ip_address = true
  tags = {
    Name = var.instance_name
  }

  root_block_device {
    volume_size = 30
    volume_type = "gp2"
  }

  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("${path.module}/../../utils/credentials/keypair.pem")
    host        = aws_instance.web.public_ip
  }

  provisioner "local-exec" {
    command = "sed -i 's/localhost/${self.public_ip}/g' ../../utils/network-components/topology/topology.py"
  }

  provisioner "file" {
    source = "../../utils/network-components"
    destination = "/home/ubuntu/network-components"
  }
 
  provisioner "remote-exec" {
    inline = [
      "sudo hostnamectl set-hostname Containernet",
      "sudo apt update",
      "curl -fsSL https://get.docker.com | bash",
      "sudo usermod -aG docker ubuntu",
      "sudo apt install -y openvswitch-switch",
      "sudo mv network-components ../../opt/",
      "chmod 777 ../../opt/network-components/start.sh",
      "sudo ./../../opt/network-components/start.sh",
    ]
  }
}

  output "instance_ip" {
    value = "link de acesso >> http://${aws_instance.web.public_ip}:8181/onos/ui/login.html"
    description = "O link de acesso à instância EC2."
  }

  output "login_info" {
    value = "User >> onos, Password >> rocks"
    description = "Informações de login."
  }