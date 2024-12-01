#!/bin/bash

AMI_ID="ami-01bc990364452ab3e"
INSTANCE_TYPE="t2.micro"
KEY_NAME="aws-key2"
SECURITY_GROUP_ID="sg-0d7ba719bbcb582f0"
SUBNET_ID="subnet-0b7fc58beff036de6"
TAG_NAME="Lab8"
USER_DATA_FILE="userdata.sh"  
IAM_ROLE_NAME="EC2-instance-profile"

if [ ! -f "$USER_DATA_FILE" ]; then
    echo "Файл $USER_DATA_FILE не знайдено в поточній папці. Переконайтесь, що він присутній."
    exit 1
fi

instance_info=$(aws ec2 run-instances \
    --image-id "$AMI_ID" \
    --count 1 \
    --instance-type "$INSTANCE_TYPE" \
    --key-name "$KEY_NAME" \
    --security-group-ids "$SECURITY_GROUP_ID" \
    --subnet-id "$SUBNET_ID" \
    --tag-specifications "ResourceType=instance,Tags=[{Key=Name,Value=$TAG_NAME}]" \
    --user-data "file://$USER_DATA_FILE" \
    --iam-instance-profile Name="$IAM_ROLE_NAME" \
    --query 'Instances[0].InstanceId' \
    --output text)

echo "Створено інстанс з ID: $instance_info"
echo "Очікуємо отримання публічної IP-адреси інстансу..."
public_ip=""
while [ -z "$public_ip" ]; do
    sleep 20
    public_ip=$(aws ec2 describe-instances \
        --instance-ids "$instance_info" \
        --query 'Reservations[0].Instances[0].PublicIpAddress' \
        --output text)
done

echo "Публічна IP-адреса інстансу: $public_ip"

if [ ! -f "$KEY_NAME.pem" ]; then
    echo "Файл ключа $KEY_NAME.pem не знайдено. Переконайтесь, що він у поточній папці."
    exit 1
fi

echo "Підключення до інстансу через SSH..."
ssh -o "StrictHostKeyChecking=no" -i "$KEY_NAME.pem" ec2-user@$public_ip
