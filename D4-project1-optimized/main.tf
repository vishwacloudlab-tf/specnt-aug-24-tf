
provider "aws" {
  region     = "us-east-1"
  #profile = "aws-b1-d1"
  profile = "specnet-tf-aug-vms"
}

/*terraform {
 backend "s3" {
   bucket = "vishwa23082024"
   #bucket = "vishwa2108202401"
   region = "us-east-1"
   key = "terraform-mod1.tfstate"
 }
}*/


module "mynet" {
    #source = "../modules/vpc-subnet"
    #source = "https://github.com/vishwacloudlab-tf/specnt-aug-24-tf/modules/vpc-subnet"
    source = "git::https://github.com/vishwacloudlab-tf/specnt-aug-24-tf.git//modules/vpc-subnet?ref=main"

    enable_ig = true # Enabling this, will create IGW, New route table, associate the subnet to RT
    vpc_cidr = "10.10.0.0/16"
    vpc_name = "vpc1" 
    tag_env = "dev" 
    tag_dep = "finance"
    public_subnets = {
    sub1 = {
        cidr_block        = "10.10.1.0/24"
        availability_zone = "us-east-1a"
        name              = "sub1"
      },
        sub2 = {
        cidr_block        = "10.10.2.0/24"
        availability_zone = "us-east-1b"
        name              = "sub2"
      }
        sub3 = {
        cidr_block        = "10.10.3.0/24"
        availability_zone = "us-east-1c"
        name              = "sub3"
      }
    }
}

module "new-key-pair" {
  source = "../modules/key-pair"
  key_name1 = "key1-aug-24"
  path = "D:\\repo\\TF-acc-19-aug-24\\D4-project1-optimized"
}

module "sgs" {
  source = "../modules/security-group"
  vpc-id = module.mynet.vpc-id
  security_groups = {
    web_sg_1 = {
      name    = "web-sg-1"
      ingress = [
        [80, 80, "tcp", ["0.0.0.0/0"]],
        [22, 22, "tcp", ["0.0.0.0/0"]]
      ]
      egress = [
        [0, 0, "-1", ["0.0.0.0/0"]]
      ]
    }
  }
}

# EC2 Instance
module "vm01" {
  source = "../modules/ec2-volume"

  #Create EC2
  subnet_id     = module.mynet.subnet-ids[0].id
  key_name      = module.new-key-pair.key-name
  enable_pub_ip = true
  sg_ids = [module.sgs.sg_ids["web_sg_1"] ]
  ami_id = "ami-066784287e358dad1"
  instance_type = "t2.micro"
  tag_env = "dev"
  filepath = "D:\\repo\\TF-acc-19-aug-24\\D4-project1-optimized\\user_data.sh"

  # Volume details
  new_volume = true
  device_name = "/dev/sdf"
  volume_size = "1"
  volume_name = "vol1-vm01"
}

output "ec2_pub_ip" {
  value = module.vm01.web_server_public_ip
  
}

