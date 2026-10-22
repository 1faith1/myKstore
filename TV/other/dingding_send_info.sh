#!/bin/bash
# dingtalk_webhook.sh
if [ $# -lt 1 ];then
    echo "用法: sh $0 消息内容"
    exit 1
fi
MSG="$1"
URL="https://oapi.dingtalk.com/robot/send?access_token=c05c*********3253525eb436313442b2*********5bc1"

curl -s -X POST "$URL" \
-H "Content-Type: application/json;charset=utf-8" \
-d '{
  "msgtype":"text",
  "at":{
    "atMobiles":[],
    "isAtAll":false
  },
  "text":{
    "content":"'"${MSG}"'"
  }
}'
