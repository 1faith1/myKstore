#!/bin/bash
# 163网易邮箱发送脚本
SMTP_SERVER="smtp.163.com"
SMTP_PORT="465"
SMTP_USER="*******@163.com"  # 163 邮箱账号, 必须与发件人一致
SMTP_PASS="G***********LQ"  # 163 客户端授权码
TO_ADDR="7******09@qq.com"    # 收件人 QQ 邮箱

if [ $# -lt 1 ];then
    echo "用法: $0 [邮件标题] 邮件内容"
    echo "示例: $0 '⚠️服务器告警' '磁盘使用率98%'"
    exit 1
fi

FROM_NAME="老六"          # 发件人信息
SUBJECT="$1"                   # [邮件标题]
BODY="${2:-系统通知}"          # 邮件内容       
# 标题base64编码，解决中文乱码
SUB_B64=$(echo -n "$SUBJECT" | base64)

RES=$(curl -s --ssl-reqd \
  --url "smtps://${SMTP_SERVER}:${SMTP_PORT}" \
  --user "${SMTP_USER}:${SMTP_PASS}" \
  --mail-from "${SMTP_USER}" \
  --mail-rcpt "${TO_ADDR}" \
  --upload-file - <<EOF
From: ${FROM_NAME} <${SMTP_USER}>
To: <${TO_ADDR}>
Subject: =?UTF-8?B?${SUB_B64}?=

${BODY}
EOF
)

if [ $? -eq 0 ];then
    echo "✅ 邮件发送成功"
else
    echo "❌ 邮件发送失败"
fi
