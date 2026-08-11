#!/data/data/com.termux/files/usr/bin/bash

# 作用：删除一个或多个group_title的所有资源
remove_group_title (){
  REMOVE_GROUP_TITLE=(\
     奥地利直播       \
     孟加拉国直播     \
     智利直播         \
     哥斯达黎加直播   \
     埃及直播         \
     西班牙直播       \
     芬兰直播         \
     印度尼西亚直播   \
     印度直播         \
     日本直播         \
     韩国直播         \
     老挝直播         \
     斯里兰卡直播     \
     墨西哥           \
     马来直播         \
     尼日利亚直播     \
     荷兰直播         \
     卡塔尔直播       \
     俄罗斯直播       \
     新加坡直播       \
     泰国直播         \
     塔吉克斯坦直播    \
     土耳其直播       \
     美国直播         \
     乌兹别克斯坦直播  \
     南非直播         \
     马来西亚直播     \
     伊拉克直播       \
  )
  echo "删除不需要的group-title..."
  SED_COMMAND_ENV=""
  for ONLY_GROUP_TITLE in ${REMOVE_GROUP_TITLE[@]}
  do
    GET_COMPLETE_GROUP_TITLE_INFO=$(grep -Eo "group-title=\".*${ONLY_GROUP_TITLE}\"" ${MY_SOURCE_FILE_NAME} |sort|uniq)
    if [[ ! -z ${GET_COMPLETE_GROUP_TITLE_INFO} ]];then
       echo "      删除 ${GET_COMPLETE_GROUP_TITLE_INFO}"
    fi
    ALL_DEL_GROUP_TITLE_NUM=$(grep -En "group-title=\".*${ONLY_GROUP_TITLE}.*\"" ${MY_SOURCE_FILE_NAME}|awk -F ":" '{print $1}')
    for ONLY_DEL_GROUP_TITLE_NUM in ${ALL_DEL_GROUP_TITLE_NUM[@]}
    do
      DEL_GROUP_TITLE_TO_ADDRESS_NUM=`echo $((${ONLY_DEL_GROUP_TITLE_NUM} + 1))`
      SED_COMMAND_ENV+=" -e ${ONLY_DEL_GROUP_TITLE_NUM},${DEL_GROUP_TITLE_TO_ADDRESS_NUM}d"
    done
  done
  if [[ ! -z ${SED_COMMAND_ENV} ]];then
    sed -i ${SED_COMMAND_ENV} ${MY_SOURCE_FILE_NAME}
  else
    echo "本次没有匹配到需要删除的group-title."
  fi
}

# 单独删除某一个/多个喜欢的节(某一个group-title里面)
del_tv_to_group_title (){
  DEL_MY_ZIDINGYI_GROUP_TITLE=$1
  if [[ -z $DEL_MY_ZIDINGYI_GROUP_TITLE ]];then
    echo '缺失删除自定义group-title不喜欢节目参数 ${自定义group-title}，用法错误' && exit 4
  fi
  DEL_NOT_LOVE_TV_LIST=(\
      ,.*熊猫频道.*     \
      ,上视东方影视     \
      ,.*频道           \
      ,中学生           \
      ,.*综合           \
      ,CGTN.*           \
      ,山东教育         \
      ,和美乡途轮播台   \
      ,快乐垂钓         \
      ,上海第一财经     \
      ,四海钓鱼         \
      ,江苏教育         \
      ,赛事最经典       \
      ,体坛名栏汇       \
      ,南方影视         \
      ,第一财经         \
      ,五星体育         \
      ,中华特产         \
      ,新动力量创一流   \
      ,最强综艺趴       \
      ,建党105周年巡礼  \
      ,24小时城市联赛轮播台  \
      ,财富天下         \
      ,江苏国际         \
      ,武术世界         \
      ,陕西体育         \
      ,辽宁体育         \
  )
  echo "单独在我自定义的group-title中删除不喜欢的节目..."
  SED_DEL_COMMAND_ENV=""
  for ONLY_DELE_NOT_LOVE_TV in ${DEL_NOT_LOVE_TV_LIST[@]}
  do
    DELE_TV_ALL_INFO=$(grep -En "group-title=\"${DEL_MY_ZIDINGYI_GROUP_TITLE}\"" ${MY_SOURCE_FILE_NAME}| \
                       grep -E "${ONLY_DELE_NOT_LOVE_TV}"|awk -F "," '{print $NF}'|sort|uniq)
    for DELE_TV_INFO in ${DELE_TV_ALL_INFO[@]}
    do
        if [[ ! -z ${DELE_TV_INFO} ]];then
            echo "      删除频道 ${DELE_TV_INFO}"
        fi
    done
    GET_DEL_ALL_TV_NUM=$(grep -En "group-title=\"${DEL_MY_ZIDINGYI_GROUP_TITLE}\"" ${MY_SOURCE_FILE_NAME}| \
                         grep -E "${ONLY_DELE_NOT_LOVE_TV}"|awk -F ":" '{print $1}')
    for DEL_TV_NUM in ${GET_DEL_ALL_TV_NUM[@]}
    do
      if [[ ! -z ${DEL_TV_NUM} ]];then
          DEL_TV_NUM_ADD_1=`echo $((${DEL_TV_NUM} + 1))`
          SED_DEL_COMMAND_ENV+=" -e ${DEL_TV_NUM},${DEL_TV_NUM_ADD_1}d"
      fi
    done
  done
  sed  -i ${SED_DEL_COMMAND_ENV} ${MY_SOURCE_FILE_NAME}
}

# 单独添加某一个/多个喜欢的节目到某一个group-title里面(在选定group-title最下面添加)
add_tv_to_group_title (){
  ADD_MY_ZIDINGYI_GROUP_TITLE=$1
  if [[ -z $ADD_MY_ZIDINGYI_GROUP_TITLE ]];then
    echo '缺失添加喜欢节目到自定组名参数，用法错误' && exit 4
  fi
  # 获取kl.txt我的自定义组中最后一个卫视的行号
  HANG_NUM=$(grep -En "group-title=\"${ADD_MY_ZIDINGYI_GROUP_TITLE}\"" ${MY_SOURCE_FILE_NAME}| \
             grep -E ",.*卫视" |tail -1|awk -F ":" '{print $1}')
  HANG_NUM_ADD_1=`echo $((${HANG_NUM} + 1))`
  ADD_LOVE_TV_LIST=(   \
      ,.*CHC家庭影院    \
      ,.*CHC动作电影    \
      ,.*CHC影迷电影    \
      ,.*凤凰中文       \
      ,.*凤凰香港       \
      ,.*凤凰资讯       \
  )
  # 确保此文件为空
  if [ -f ${MYLOVETV_1} ];then
     rm -f ${MYLOVETV_1}*
  fi
  echo "单独添加喜欢的节目到我自定义的group-title中..."
  for ONLY_LOVE_TV in ${ADD_LOVE_TV_LIST[@]}
  do
      NEW_ADD_TV_INFO=$(grep -Eo "${ONLY_LOVE_TV}" ${NEW_SOURCE_FILE_NAME} |sort |uniq|awk -F "," '{print $2}')
      if [[ ! -z ${NEW_ADD_TV_INFO} ]];then
         echo "      新增节目 ${NEW_ADD_TV_INFO}"
      fi
      for GUOLV_HTTP_ADDRESS in $(grep -EA 1 "${ONLY_LOVE_TV}" ${NEW_SOURCE_FILE_NAME}|sed "/^--/d"|grep -E "^http")
      do
          if [[ $(grep ${GUOLV_HTTP_ADDRESS} ${NEWFILE_2}|wc -l) == 0 ]];then
              grep -B 1 "${GUOLV_HTTP_ADDRESS}" ${NEW_SOURCE_FILE_NAME}|sed "/^--/d" >> ${MYLOVETV_1}
          fi
      done
  done
  # 修改group-title为自定义的group-title
  sed -i "s/group-title=.*\,/group-title=\"${ADD_MY_ZIDINGYI_GROUP_TITLE}\"\,/g" ${MYLOVETV_1}
  # 将喜欢的节目加入到kl.txt中
  sed -i "${HANG_NUM_ADD_1}r ${MYLOVETV_1}" ${MY_SOURCE_FILE_NAME}
}

# 作用：下载需要的文件并处理(合并成我需要的样式)
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

  # 删除${MY_SOURCE_FILE_NAME}旧数据
  echo "删除 ${MY_SOURCE_FILE_NAME}文件中的旧源数据"
  sed -i "${ME_FILE_ONE_NUM},${ME_FILE_TWO_NUM}d" ${MY_SOURCE_FILE_NAME}

  # ==================== 处理${NEW_SOURCE_FILE_NAME}文件数据
  NEW_FILE_NUM=$(grep -En  "TG频道" ${NEW_SOURCE_FILE_NAME}|grep "官网地址"|awk -F ":" '{print $1}')
  echo "处理${NEW_SOURCE_FILE_NAME}文件中数据，删除TG等无关信息"
  sed -i -e "1d" -e "${NEW_FILE_NUM},`echo $((${NEW_FILE_NUM} + 1))`d" ${NEW_SOURCE_FILE_NAME}

  # ====
  echo "添加处理后的${NEW_SOURCE_FILE_NAME}文件中源到${MY_SOURCE_FILE_NAME}文件中"
  sed -i "${FIND_ME_FILE_ONE_NUM}r ${NEW_SOURCE_FILE_NAME}" ${MY_SOURCE_FILE_NAME}
  echo "更新${MY_SOURCE_FILE_NAME}文件中时间信息"
  sed -i "s/更新时间.*/更新时间${NEW_DATE}/g" ${MY_SOURCE_FILE_NAME}
}

# 作用：单独添加一个我需要的group_title
custom_yangweishi(){
  ADD_MY_ZIDINGYI_GROUP_TITLE=$1
  if [[ -z $ADD_MY_ZIDINGYI_GROUP_TITLE ]];then
    echo '缺失自定组名参数，用法错误' && exit 4
  fi
  # 确保两个文件为空
  if [ -f ${NEWFILE_1} ];then
     rm -f ${NEWFILE_1}*
  fi
  if [ -f ${NEWFILE_2} ];then
    rm -f ${NEWFILE_2}*
  fi
  # 获取全部ys/ws的group-title并且去重
  GET_ALL_YANGWEISHI_GROUPTITLE=$(grep -Ei "cctv1|北京卫视|东方卫视|辽宁卫视" ${NEW_SOURCE_FILE_NAME} |\
                                grep -E -o "group-title=.*,"|sed 's/,//g'|sort|uniq|grep -Ev "体育|内网|ITV")
  echo "本次整合group-title全部节目到我自定义group-title中，整合group-title列表信息如下："
  # // 处理文件：根据上面GET_ALL_YANGWEISHI_GROUPTITLE进行遍历获取需要的ys/ws到NEWFILE_1文件
  for group_title in ${GET_ALL_YANGWEISHI_GROUPTITLE[@]}
  do
    echo "      整合 ${group_title}"
    GET_GROUP_TATLE_VALUE=$(echo ${group_title}|awk -F "\"" '{print $2}')
    grep -A 1 -F -- ${GET_GROUP_TATLE_VALUE}  ${NEW_SOURCE_FILE_NAME} >>${NEWFILE_1}
  done

  # // 处理文件：将NEWFILE_1文件中的ys/ws先放在NEWFILE_2文件中
  grep -Ei  ",.*cctv" -A 1 ${NEWFILE_1}|sed "/^--/d" >> ${NEWFILE_2}
  grep -Ei  ",.*卫视" -A 1 ${NEWFILE_1}|sed "/^--/d" >> ${NEWFILE_2}
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
  sed -e "$(grep -nEi ",.*CCTV|,.*卫视" ${NEWFILE_1} | cut -d: -f1 | awk '{printf "%dd;%dd;",$0,$0+1}')" ${NEWFILE_1}  >> ${NEWFILE_2}
  # 修改/group-title为自定义的group-title
  sed -i "s/group-title=.*\,/group-title=\"${ADD_MY_ZIDINGYI_GROUP_TITLE}\"\,/g" ${NEWFILE_2}

  # // 添加处理好的文件到kl文本中的第一行
  # 查找文本中"#============="所在行数
  FIND_ME_FILE_ONE_NUM=$(grep -En "#=====+" ${MY_SOURCE_FILE_NAME} |head -1|awk -F ":" '{print $1}')
  # ====
  echo "添加新group-title的源到${MY_SOURCE_FILE_NAME}文件中..."
  sed -i "${FIND_ME_FILE_ONE_NUM}r ${NEWFILE_2}" ${MY_SOURCE_FILE_NAME}
}

# 作用：上传本次修改好的文件
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

# 作用：全局变量
env_load (){
  NEW_DATE=$(date +%Y.%m.%d)
  SIM_DATE=$(date +%m.%d)
  # 下载源文件到本地处理的目录
  FILE_DIR_ADD=$(cd $(dirname "$0") ; pwd)
  LOCAL_SOURCE_FILE_DIR=${FILE_DIR_ADD}/localSource
  #LOCAL_SOURCE_FILE_DIR=/tmp/localSource
  NEWFILE_1="${LOCAL_SOURCE_FILE_DIR}/tvall.1.m3u"
  NEWFILE_2="${LOCAL_SOURCE_FILE_DIR}/tvall.2.m3u"
  # 我喜欢的节目过滤出来后存放的目录
  MYLOVETV_1="${LOCAL_SOURCE_FILE_DIR}/mylove.1.m3u"
  # github下载项目目录地址
  #GITHUB_SOURCE_FILE_DIR=/tmp/githubSource
  GITHUB_SOURCE_FILE_DIR=${FILE_DIR_ADD}/githubSource
  # 我的源，下载到本地后进行处理内容
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
  # 我自定义的新加组名称
  ADD_MY_ZIDINGYI_GROUP_TITLE_1="🔥TV汇总-${SIM_DATE}"
}

main (){
  env_load
  mkdir -p ${LOCAL_SOURCE_FILE_DIR}
  mkdir -p ${GITHUB_SOURCE_FILE_DIR}
  
  cd ${LOCAL_SOURCE_FILE_DIR}
  local_chuli_yuan_source
  remove_group_title
  custom_yangweishi     ${ADD_MY_ZIDINGYI_GROUP_TITLE_1}
  del_tv_to_group_title ${ADD_MY_ZIDINGYI_GROUP_TITLE_1}
  add_tv_to_group_title ${ADD_MY_ZIDINGYI_GROUP_TITLE_1}
  
  cd ${GITHUB_SOURCE_FILE_DIR}
  upload_migu_to_github
}
# =================================================================
main

