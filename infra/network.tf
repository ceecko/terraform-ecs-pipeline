resource "aws_default_vpc" "default" {

}

resource "aws_default_subnet" "default_eu_west_1a" {
  availability_zone = "eu-west-1a"
}

resource "aws_default_subnet" "default_eu_west_1b" {
  availability_zone = "eu-west-1b"
}
