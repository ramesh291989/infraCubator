# #!/bin/bash
#    echo "*** Installing apache2"
#    sudo apt -y update
#    sudo apt install -y apache2
#    echo "*** Completed Installing apache2"
    sudo yum update -y
    sudo yum install -y httpd
    sudo systemctl start httpd
    sudo systemctl enable httpd