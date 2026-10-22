!/bin/bash
# wecom_robot.sh 企业微信群机器人webhook
if [ $# -lt 1 ];then
    echo "用法: $0 消息内容"
    echo "示例: $0 '【告警】服务器CPU负载过高'"
    exit 1
fi

MSG="$1"
# 替换成你自己机器人的webhook地址
WEBHOOK_URL="https://qyapi.weixin.qq.com/cgi-bin/webhook/send?key=xxxxxxxxxxxxxxxxxxxx"

curl -s -X POST "$WEBHOOK_URL" \
-H "Content-Type: application/json;charset=utf-8" \
-d '{
  "msgtype":"text",
  "text":{
    "content":"'"${MSG}"'",
    "mentioned_list":[],
    "mentioned_mobile_list":[]
  }
}'
