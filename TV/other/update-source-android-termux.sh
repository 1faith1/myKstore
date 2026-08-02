
#!/data/data/com.termux/files/usr/bin/bash

local_chuli_yuan_source(){
  #NEW_DATE=$(date +%Y.%m.%d)
  #MY_SOURCE_ADD='https://gh-proxy.org/https://raw.githubusercontent.com/YONGHU01/myREPO/refs/heads/main/TV/test.txt'
  #NEW_SOURCE_ADD='https://live.152319.xyz/live.m3u'
  #MY_SOURCE_FILE_NAME=$( echo ${MY_SOURCE_ADD} |awk -F "/" '{print $NF}')
  #NEW_SOURCE_FILE_NAME=$(echo ${NEW_SOURCE_ADD}|awk -F "/" '{print $NF}')

  if [ -f ${MY_SOURCE_FILE_NAME} ];then
     rm -f ${MY_SOURCE_FILE_NAME}*
  fi
  if [ -f ${NEW_SOURCE_FILE_NAME} ];then
    rm -f ${NEW_SOURCE_FILE_NAME}*
  fi

  # 下载我得源文件和更新源文件
  wget  --tries=1 ${MY_SOURCE_ADD}
  if [ $? -ne 0 ];then
    echo "下载${MY_SOURCE_FILE_NAME}文件失败"
    exit 4
  fi
  wget  --tries=1 ${NEW_SOURCE_ADD}
  if [ $? -ne 0 ];then
    echo "下载${NEW_SOURCE_FILE_NAME}文件失败"
    exit 4
  fi
  # 查找文本中"#============="所在行数
  FIND_ME_FILE_ONE_NUM=$(grep -En "#=====+" ${MY_SOURCE_FILE_NAME} |head -1|awk -F ":" '{print $1}')
  FIND_ME_FILE_TWO_NUM=$(grep -En "#=====+" ${MY_SOURCE_FILE_NAME} |tail -1|awk -F ":" '{print $1}')
  # 将行数进行加减法，应用于删除旧数据,添加新数据
  ME_FILE_ONE_NUM=`echo $((${FIND_ME_FILE_ONE_NUM} + 1))`
  ME_FILE_TWO_NUM=`echo $((${FIND_ME_FILE_TWO_NUM} - 1))`

  # 删除${meFile}旧数据
  sed -i "${ME_FILE_ONE_NUM},${ME_FILE_TWO_NUM}d" ${MY_SOURCE_FILE_NAME}

  # ==================== 处理${NEW_SOURCE_FILE_NAME}文件数据
  NEW_FILE_NUM=$(grep -En  "TG频道" live.m3u|grep "官网地址"|awk -F ":" '{print $1}')
  echo '处理其他源文件中数据，删除TG等无关信息'
  sed -i -e "1d" -e "${NEW_FILE_NUM},`echo $((${NEW_FILE_NUM} + 1))`d" ${NEW_SOURCE_FILE_NAME}


  # ====
  echo '添加其他源到文件中'
  sed -i "${FIND_ME_FILE_ONE_NUM}r ${NEW_SOURCE_FILE_NAME}" ${MY_SOURCE_FILE_NAME}
  echo '更新我的文件中时间信息'
  sed -i "s/更新时间.*/更新时间${NEW_DATE}/g" ${MY_SOURCE_FILE_NAME}
}

custom_yangweishi(){
  # 确保两个文件为空
  if [ -f ${NEWFILE_1} ];then
     rm -f ${NEWFILE_1}*
  fi
  if [ -f ${NEWFILE_2} ];then
    rm -f ${NEWFILE_2}*
  fi
  # 获取全部ys/ws的group-title并且去重
  GET_ALL_YANGWEISHI_GROUPTITLE=$(grep -i cctv ${NEW_SOURCE_FILE_NAME} |grep -E -o "group-title=.*\,"|sed 's/,//g'|sort|uniq|grep -Ev "体育|内网|ITV")

  # // 处理文件：根据上面GET_ALL_YANGWEISHI_GROUPTITLE进行遍历获取需要的ys/ws到NEWFILE_1文件
  for group_title in ${GET_ALL_YANGWEISHI_GROUPTITLE[@]}
  do
    echo ${group_title}
    GET_GROUP_TATLE_VALUE=$(echo ${group_title}|awk -F "\"" '{print $2}')
    grep -A 1 -F -- ${GET_GROUP_TATLE_VALUE}  ${NEW_SOURCE_FILE_NAME} >>${NEWFILE_1}
  done

  # // 处理文件：将NEWFILE_1文件中的ys/ws先放在NEWFILE_2文件中
  grep -Ei  ",cctv" -A 1 ${NEWFILE_1}|sed "/^--/d" >> ${NEWFILE_2}
  grep -Ei  "卫视" -A 1 ${NEWFILE_1}|sed "/^--/d" >> ${NEWFILE_2}
  # 在NEWFILE_2文件中转换所有带中文的ys名字为统一的ys名
  # 获取NEWFILE_2中所有ys除带欧美的名字
  GET_CCTV_CHINESE=$(awk -F "," '{print $NF}' ${NEWFILE_2} |grep -Ev "^http"|grep -i "cctv"|grep -Ev "欧|美"|sort|uniq)
  for ONLY_CCTV_CHINESE in ${GET_CCTV_CHINESE[@]}
  do
    # 将ys的英文名字全部变为大写字母
    UP_CCTV_CHINESE=$(echo ${ONLY_CCTV_CHINESE}|grep -Eio "[a-z]+[0-9]{1,2}|[a-z]+[0-9]{1,2}\+"|tr '[:lower:]' '[:upper:]')
    sed -i  "s/,${ONLY_CCTV_CHINESE}/,${UP_CCTV_CHINESE}/g" ${NEWFILE_2}
  done
  # # // 处理文件：将根据GET_ALL_YANGWEISHI_GROUPTITLE找到的所有pd，除上面ys/ws外所有pd追加到NEWFILE_2文件
  awk -v IGNORECASE=1 '(index(tolower($0),",cctv")>0)||(index($0,"卫视")>0){skip=1;next}skip==1{skip=0;next}1' ${NEWFILE_1} >> ${NEWFILE_2}
  # 修改/group-title为自定义的group-title
  sed -i "s/group-title=.*\,/group-title=\"TV汇总-${NEW_DATE}\"\,/g" ${NEWFILE_2}

  # // 添加处理好的文件到kl文本中的第一行
  # 查找文本中"#============="所在行数
  FIND_ME_FILE_ONE_NUM=$(grep -En "#=====+" ${MY_SOURCE_FILE_NAME} |head -1|awk -F ":" '{print $1}')
  # ====
  echo '添加其他源到文件中'
  sed -i "${FIND_ME_FILE_ONE_NUM}r ${NEWFILE_2}" ${MY_SOURCE_FILE_NAME}
}

upload_migu_to_github(){
  set -e
  # ====== 配置区 ======
  #USER_NAME='YONGHU01'
  # 仓库名
  #REPO_NAME='myREPO'
  #LOCAL_UPLOAD_FILE_NAME="test.txt"
  LOCAL_UPLOAD_FILE_NAME="${MY_SOURCE_FILE_NAME}"
  #LOCAL_UPLOAD_FILE_ADD="${LOCAL_SOURCE_FILE_DIR}/test.txt"
  LOCAL_UPLOAD_FILE_ADD="${LOCAL_SOURCE_FILE_DIR}/${MY_SOURCE_FILE_NAME}"
  #BRANCH="main"
  #LOCAL_REPO_DIR="${GITHUB_SOURCE_FILE_DIR}"
  TV_DIR=${LOCAL_REPO_DIR}/TV
  # 仓库地址
  REPO_URL="https://github.com/${USER_NAME}/${REPO_NAME}.git"
  ## ======= 使用公钥连接github地址
  ## 本地生成ssh-key，执行ssh-keygen命令
  ## github设置公钥模式允许本地机器访问
  ##    公钥上传地址https://github.com/settings/keys
  ##    点击New SSH keys 填入本地/root/.ssh/id_rsa.pub中内容,名称任意填写直接add
  ##    添加完成后再本地机器上测试,执行命令：ssh -T git@github.com
  REMOTE_ADD="git@github.com:${USER_NAME}/${REPO_NAME}.git"
  # ====================
  echo "1. 检查源文件..."
  if [ ! -f "$LOCAL_UPLOAD_FILE_ADD" ]; then
    echo "文件不存在: $LOCAL_UPLOAD_FILE_ADD"
    exit 1
  fi

  echo "2. 初始化或更新仓库..."

  if [ ! -d "$LOCAL_REPO_DIR/.git" ]; then
    rm -rf "${LOCAL_REPO_DIR}/*"
    git clone "$REPO_URL" "$LOCAL_REPO_DIR"
  else
    cd "$LOCAL_REPO_DIR"
    git fetch origin
    git reset --hard origin/$BRANCH
  fi
  cd "$LOCAL_REPO_DIR"
  echo "3. 覆盖文件..."
  \cp -f "$LOCAL_UPLOAD_FILE_ADD" "$TV_DIR/$LOCAL_UPLOAD_FILE_NAME"

  echo "4. 提交变更..."
  git add "${TV_DIR}/${LOCAL_UPLOAD_FILE_NAME}"

  # 判断是否有变化（避免空提交报错）
  if git diff --cached --quiet; then
    echo "无变化，跳过提交"
    exit 0
  fi

  git commit -m "update mg.txt $(date '+%F %T')"

  echo "5. 推送到GitHub（覆盖远端）..."
  git remote set-url origin ${REMOTE_ADD}
  git push origin $BRANCH

  echo "完成上传"
}
# =================================================================
NEW_DATE=$(date +%Y.%m.%d)
# 下载源文件到本地处理的目录
DIR_1=$(pwd)
LOCAL_SOURCE_FILE_DIR=${DIR_1}/localSource
NEWFILE_1="${LOCAL_SOURCE_FILE_DIR}/tvall.1.m3u"
NEWFILE_2="${LOCAL_SOURCE_FILE_DIR}/tvall.2.m3u"
# github下载项目目录地址
GITHUB_SOURCE_FILE_DIR=${DIR_1}/githubSource
# 我得源，下载到本地后进行处理内容
MY_SOURCE_ADD='https://gh-proxy.org/https://raw.githubusercontent.com/1faith1/myKstore/refs/heads/main/TV/kl.txt'
# 截断文件名（test.txt）
MY_SOURCE_FILE_NAME=$( echo ${MY_SOURCE_ADD} |awk -F "/" '{print $NF}')
# 官方源，下载到本地后处理内容
NEW_SOURCE_ADD='https://live.445569.xyz/live.m3u'
# 截断文件名（live.m3u）
NEW_SOURCE_FILE_NAME=$(echo ${NEW_SOURCE_ADD}|awk -F "/" '{print $NF}')
# github用户名
USER_NAME='1faith1'
# 仓库名
REPO_NAME='myKstore'
# 分支名
BRANCH="main"
LOCAL_REPO_DIR="${GITHUB_SOURCE_FILE_DIR}"
TV_DIR=${LOCAL_REPO_DIR}/TV

mkdir -p ${LOCAL_SOURCE_FILE_DIR}
mkdir -p ${GITHUB_SOURCE_FILE_DIR}

cd ${LOCAL_SOURCE_FILE_DIR}
local_chuli_yuan_source
custom_yangweishi
cd ${GITHUB_SOURCE_FILE_DIR}
upload_migu_to_github
