provider "aws" {
  region  = "eu-west-1"
  profile = "myTeraaformProfile"
}

resource "aws_s3_bucket" "myBucket" { 
  bucket = "my-tf-bucket001" 
  tags = { 
    Name        = "My bucket" 
    Environment = "Dev" 
  } 
}

resource "aws_s3_bucket_ownership_controls" "ownerwhip" {
  bucket = aws_s3_bucket.myBucket.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "acl" {
  bucket = aws_s3_bucket.myBucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}
// Upload file 
resource "aws_s3_object" "myFirstObject" { 
bucket = "${aws_s3_bucket.myBucket.id}" 
key    = "myTestFile.txt" 
source = "testFiles/testFile.txt" 
etag = "${md5(file("testFiles/testFile.txt"))}" 
} 
// Key pair 
resource "aws_key_pair" "myKeyPair" { 
key_name   = "deployer-key" 
public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC+PvQFW/LX6vTsK7H/0eCZET6tHk6LyTzPydExyBTf+gkdY4YUh12Mrld9Vt1hPa24NIOZG0uWegPdCc8UAL2ZiRf7FcyyysGEU+7GDk1F+o1xoDoAXO2sMR9MxWxyTfyOaU+Wf/dYgww3rI9IJXYZCjthZlGtOtfNlWumxEA+OaPjZHpmd5g2izBS7Mtxf4zpkuvexjHyXOX+z0EIzttTmPuqklKYgT50J9Qgzoz9wjZ6vw22ys/gXt0xR7cLSx+z8ouwi9FBSO0JOV19Zsl/ze+ZrBZo1RtpVB0q/2yehogHL4RcYZOO4V4O1HlJUXEz5lna/Kue++LsdsoS9nLc2r7hCOyjy1HMsR0JW0MWg6IKtdt5Y8HNXvY3FDVpMaD9DsPoEUr7QAxbSAOFe6aA9uFKdC5TCxS2lEMFDFUMKboJBn+yc4sE0yVYlGff0JgTT0VRAs7SAdHMvnefuprRknUOslHlF+9nP31BhD8UzK3i4HiHcNwfVhwbfu1B/5zJCDHKalebh3o9yw1VsqjNLl3HDMaZGNI/CfeEFBwBzvbtGUPhkQBLah4aJB+UGugLLmXaWdmI8JChwMZfH/OjXpIYAIhaWSkrVMSGAFevsiY3CNZ+qITC+qet9/cSjhni2i/fiWrB5hwGLR2SUeoz8wQ+IDaJGB4vpHWEkMYaiw== nene@nene-VirtualBox"
} 
 
// Variable 
variable "vpc" { 
    type = string 
    default = "vpc-0f80f3beffa31b314" 
} 
 
// Security group 
resource "aws_security_group" "terraformEc2SG" { 
  name        = "terraformEc2SG" 
  description = "Terraform security Group for Ec2" 
  vpc_id      = "${var.vpc}" 
 
  ingress { 
    description      = "SSH from VPC" 
    from_port        = 22 
    to_port          = 22 
    protocol         = "tcp" 
    cidr_blocks      = ["0.0.0.0/0"] 
  } 
 
  egress { 
    from_port        = 22 
    to_port          = 22 
    protocol         = "tcp" 
    cidr_blocks      = ["0.0.0.0/0"] 
  } 
 
  tags = { 
    Name = "SSH from VPC" 
  } 
} 
 
// Variable AMI  
variable "amiId" { 
    type = string 
    default = "ami-0932dacac40965a65" 
} 
 
// Ec2 
resource "aws_instance" "terraformEc2Instance" { 
  ami           = "${var.amiId}" 
  instance_type = "t2.micro" 
  key_name = "deployer-key" 

vpc_security_group_ids = ["${aws_security_group.terraformEc2SG.id}"] 
tags = { 
Name = "terraformEc2Instance" 
} 
} 