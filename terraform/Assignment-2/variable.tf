variable region {
type = string
default = "eu-north-1"
}

variable profile {
type = string
default = "160071257600_PowerUserPlusRole"
}

variable cidrblock {
type = string
default = "10.0.0.0/16"
}

variable public_cidrblock {
type = string
default = "10.0.0.0/24"
}

variable tagname {
type = string
default = "main"
}

variable ami {
type = string
default = "ami-0416c18e75bd69567"
}

variable instance-type {
type = string
default = "t3.micro"
}

variable hostedzoneid {
type = string
default = "Z05710631SDXHX3A09W99"
}

variable sitedomain {
type = string
default = "test-infra"
}