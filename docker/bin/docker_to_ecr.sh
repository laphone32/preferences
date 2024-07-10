#!/usr/bin/env bash

if [ "$#" -lt 2 ]; then
    echo "usage: $0 <profile> <image>"
fi

profile=$1
image=$2

profile_set="--profile $profile"

account_id=$(aws sts get-caller-identity --query 'Account' --output text $profile_set)
echo "account_id=$account_id"

region=$(aws configure get region $profile_set)
echo "region=$region"

uri=${account_id}.dkr.ecr.${region}.amazonaws.com
echo "uri=$uri"

aws sso login $profile_set

docker tag $image $uri

docker login --username AWS --password $(aws ecr get-login-password --region $region $profile_set) $uri

docker push $uri/$image


