#!/data/data/com.termux/files/usr/bin/bash
TMP_Q_DIR=Q.txt
TMP_A_DIR=A.txt
TMP_ALL_Q_A=ALL_A_Q.txt

KS_CHENGCHUFA (){
    local total=$1
    local i=0
    local ALL_KS=()
    local ALL_KS_ANS=()
    while [[ $i -lt $total ]]; do
      GENERATE_ONE_NUM_NULL_ZERO=$((1 + RANDOM %9))
      GENERATE_ONE_NUM_FIRST_NUM_NULL_ONETWO=$((2 + RANDOM %9))
      GENERATE_TWO_NUM=$((10 + RANDOM %90))
      GENERATE_THREE_NUM=$((100 + RANDOM %900))

      RANGE_FIRST_NUM=($GENERATE_THREE_NUM   $GENERATE_TWO_NUM)
      FIRST_NUM=${RANGE_FIRST_NUM[$(( RANDOM % ${#RANGE_FIRST_NUM[@]} ))]}

      RANGE_SECOND_NUM=($GENERATE_ONE_NUM_FIRST_NUM_NULL_ONETWO ${GENERATE_ONE_NUM_NULL_ZERO}0)
      SECOND_NUM=${RANGE_SECOND_NUM[$(( RANDOM % ${#RANGE_SECOND_NUM[@]} ))]}

      CALC=$((RANDOM%2))
      if (( CALC == 0 ));then
        OP='÷'
        (( FIRST_NUM % SECOND_NUM == 0 )) || continue
        RES=$((FIRST_NUM / SECOND_NUM))
      else
        OP='×'
        RES=$((FIRST_NUM * SECOND_NUM))
      fi

      ALL_KS+=("${FIRST_NUM} ${OP} ${SECOND_NUM} =")
      ALL_KS_ANS+=("${FIRST_NUM} ${OP} ${SECOND_NUM} = ${RES}")
      ((i++))
    done

    print4(){
      local cnt=0
      for s in "$@";do
        printf "%-26s" "$s"
        ((cnt++))
        ((cnt%4==0)) && echo
      done
      ((cnt%4!=0)) && echo
    }

    echo "一、口算(每天${total}道)"       >>${TMP_Q_DIR}
    print4 "${ALL_KS[@]}" >>${TMP_Q_DIR}
    echo -e "\n一、口算(每天${total}道)【答案】"      >> ${TMP_A_DIR}
    print4 "${ALL_KS_ANS[@]}" >> ${TMP_A_DIR}
}

TUOSHI (){
    ops=("+" "-" "*" "/")
    total=$1
    ALL_KS=()
    ALL_ANS=()
    for ((i=0; i<total; i++)); do
        while true; do
            shape=$((RANDOM % 3))
            op1=${ops[$((RANDOM %4))]}
            op2=${ops[$((RANDOM %4))]}
            expr=""
            step1=""
            step2=""
            valid=1
            inner=0
            mid=0
            res=0
            a=0;b=0;c=0
            case $shape in
                0)
                    if [[ $op1 == "/" ]];then
                        b=$((2 + RANDOM % 99))
                        a=$(( b * (2 + RANDOM % 100) ))
                    else
                        a=$((1 + RANDOM % 100))
                        b=$((1 + RANDOM % 100))
                    fi
                    inner=$((a $op1 b))
                    if [[ $op2 == "/" ]];then
                        if (( inner <= 1 ));then valid=0; continue; fi
                        factors=()
                        for ((k=2;k<inner;k++));do
                            if (( inner % k == 0 ));then
                                factors+=($k)
                            fi
                        done
                        if (( ${#factors[@]} == 0 ));then valid=0; continue; fi
                        c=${factors[$((RANDOM % ${#factors[@]}))]}
                    else
                        c=$((1 + RANDOM % 100))
                    fi
                    res=$(( inner $op2 $c ))
                    expr="($a $op1 $b) $op2 $c"
                    step1="=$inner $op2 $c"
                    step2="=$res"
                    ;;
                1)
                    if [[ $op2 == "/" ]];then
                        c=$((2 + RANDOM % 99))
                        b=$(( c * (2 + RANDOM % 100) ))
                    else
                        b=$((1 + RANDOM % 100))
                        c=$((1 + RANDOM % 100))
                    fi
                    inner=$((b $op2 $c))
                    if [[ $op1 == "/" ]];then
                        if (( inner <= 1 ));then valid=0; continue; fi
                        a=$(( inner * (2 + RANDOM % 100) ))
                    else
                        a=$((1 + RANDOM % 100))
                    fi
                    res=$(( a $op1 $inner ))
                    expr="$a $op1 ($b $op2 $c)"
                    step1="=$a $op1 $inner"
                    step2="=$res"
                    ;;
                2)
                    op1_prio=0
                    op2_prio=0
                    [[ $op1 == "*" || $op1 == "/" ]] && op1_prio=1
                    [[ $op2 == "*" || $op2 == "/" ]] && op2_prio=1
                    if (( op1_prio >= op2_prio ));then
                        if [[ $op1 == "/" ]];then
                            b=$((2 + RANDOM % 99))
                            a=$(( b * (2 + RANDOM % 100) ))
                        else
                            a=$((1 + RANDOM % 100))
                            b=$((1 + RANDOM % 100))
                        fi
                        mid=$((a $op1 b))
                        if [[ $op2 == "/" ]];then
                            if (( mid <= 1 ));then valid=0; continue; fi
                            factors=()
                            for ((k=2;k<mid;k++));do
                                if (( mid % k == 0 ));then
                                    factors+=($k)
                                fi
                            done
                            if (( ${#factors[@]} == 0 ));then valid=0; continue; fi
                            c=${factors[$((RANDOM % ${#factors[@]}))]}
                        else
                            c=$((1 + RANDOM % 100))
                        fi
                        res=$(( mid $op2 $c ))
                        expr="$a $op1 $b $op2 $c"
                        step1="=$mid $op2 $c"
                        step2="=$res"
                    else
                        if [[ $op2 == "/" ]];then
                            c=$((2 + RANDOM % 99))
                            b=$(( c * (2 + RANDOM % 100) ))
                        else
                            b=$((1 + RANDOM % 100))
                            c=$((1 + RANDOM % 100))
                        fi
                        mid=$((b $op2 $c))
                        if [[ $op1 == "/" ]];then
                            if (( mid <= 1 ));then valid=0; continue; fi
                            a=$(( mid * (2 + RANDOM % 100) ))
                        else
                            a=$((1 + RANDOM % 100))
                        fi
                        res=$(( a $op1 $mid ))
                        expr="$a $op1 $b $op2 $c"
                        step1="=$a $op1 $mid"
                        step2="=$res"
                    fi
                    ;;
            esac
            if (( res >= 0 && valid == 1 ));then
                break
            fi
        done
        q_str="${expr} ="
        q_str=${q_str//\*/×}
        q_str=${q_str//\//÷}
        s1=${step1//\*/×}
        s1=${s1//\//÷}
        s2=${step2//\*/×}
        s2=${s2//\//÷}
        ans_str="${q_str}
    $s1
    $s2"
        ALL_KS+=("$q_str")
        ALL_ANS+=("$ans_str")
    done
    echo "二、脱式(每天${total}道)" >> ${TMP_Q_DIR}
    {
    cnt=0
    for item in "${ALL_KS[@]}"; do
        printf "%-36s" "$item"
        ((cnt++))
        (( cnt %4 == 0 )) && echo
    done
    (( cnt %4 != 0 )) && echo
    } >> ${TMP_Q_DIR}
    echo -e "\n二、脱式(每天${total}道)【答案】" >> ${TMP_A_DIR}
    {
    for ans in "${ALL_ANS[@]}";do
        echo "$ans"
        echo
    done
    } >> ${TMP_A_DIR}
}

SHUSHI (){
    total=$1
    ALL_KS=()
    ALL_ANS=()

    for ((i=0; i<total; i++)); do
        while true; do
            A=$(( 10 + RANDOM % 990 ))
            lenA=${#A}
            B=0
            lenB=0

            if (( lenA == 2 )); then
                B=$((10 + RANDOM % 90))
            else
                if (( RANDOM %2 ==0 ));then
                    B=$((10 + RANDOM %90))
                else
                    B=$((100 + RANDOM %900))
                fi
            fi
            lenB=${#B}

            if (( B < A && lenB <= lenA && lenB >=2 ));then
                break
            fi
        done

        q="${A} × ${B} ="
        ALL_KS+=("$q")
        product=$((A * B))
        ans_str="${A} × ${B} = ${product}"
        ALL_ANS+=("$ans_str")
    done

    echo "三、竖式(每天${total}道)" >> ${TMP_Q_DIR}
    line=""
    cnt=0
    for item in "${ALL_KS[@]}"; do
        line+=$(printf "%-25s" "$item")
        ((cnt++))
        if (( cnt %4 == 0 ));then
            echo "$line" >> ${TMP_Q_DIR}
            line=""
        fi
    done
    if [[ -n $line ]];then
        echo "$line" >> ${TMP_Q_DIR}
    fi

    echo "三、竖式(每天${total}道)【答案】" >> ${TMP_A_DIR}
    line=""
    cnt=0
    for item in "${ALL_ANS[@]}"; do
        line+=$(printf "%-25s" "$item")
        ((cnt++))
        if (( cnt %4 == 0 ));then
            echo "$line" >> ${TMP_A_DIR}
            line=""
        fi
    done
    if [[ -n $line ]];then
        echo "$line" >> ${TMP_A_DIR}
    fi
}

# 先清空旧临时文件
> ${TMP_Q_DIR}
> ${TMP_A_DIR}
> ${TMP_ALL_Q_A}

#一、口算(每天20道)
KS_CHENGCHUFA '20'
printf '\n%.0s' {1..2} >>${TMP_Q_DIR}
printf '\n%.0s' {1..2} >>${TMP_A_DIR}

#二、脱式(每天2道)
TUOSHI '2'
printf '\n%.0s' {1..2} >>${TMP_Q_DIR}
printf '\n%.0s' {1..2} >>${TMP_A_DIR}

#三、竖式(每天10道)
SHUSHI '10'

#合并输出
cat ${TMP_Q_DIR} >> ${TMP_ALL_Q_A}
printf '\n%.0s' {1..10} >> ${TMP_ALL_Q_A}
echo "==================================【答案】==================================" >> ${TMP_ALL_Q_A}
cat ${TMP_A_DIR} >> ${TMP_ALL_Q_A}

#终端输出完整试卷
cat  ${TMP_ALL_Q_A}
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
  TV_DIR=${LOCAL_REPO_DIR}/TEST
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
  # github下载项目目录地址
  #GITHUB_SOURCE_FILE_DIR=/tmp/githubSource
  GITHUB_SOURCE_FILE_DIR=${FILE_DIR_ADD}/githubSource
  # 截断文件名（test.txt）
  MY_SOURCE_FILE_NAME=ALL_A_Q.txt
  # github用户名
  USER_NAME='1faith1'
  # 仓库名
  REPO_NAME='myKstore'
  # 分支名
  BRANCH="main"
  LOCAL_REPO_DIR="${GITHUB_SOURCE_FILE_DIR}"
  TV_DIR=${LOCAL_REPO_DIR}/TEST
}
env_load
upload_migu_to_github
#清理临时文件，保留最终ALL_A_Q.txt
rm -f ${TMP_Q_DIR} ${TMP_A_DIR}
echo ""
echo "生成完成，文件保存为: ALL_A_Q.txt"

