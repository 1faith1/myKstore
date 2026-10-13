#!/bin/bash

TMP_Q_DIR=Q.txt
TMP_A_DIR=A.txt
TMP_ALL_Q_A=ALL_A_Q.txt

KS_CHENGCHUFA (){
    local total=$1
    local i=0
    local ALL_KS=() 
    local ALL_KS_ANS=()
    while [[ $i -lt $total ]]; do
      # 随机各类数字
      GENERATE_ONE_NUM_NULL_ZERO=$((1 + RANDOM %9))
      GENERATE_ONE_NUM_FIRST_NUM_NULL_ONETWO=$((2 + RANDOM %9))
      GENERATE_TWO_NUM=$((10 + RANDOM %90))
      GENERATE_THREE_NUM=$((100 + RANDOM %900))
  
      # 随机取第一个数字：三位数 / 二位数二选一
      RANGE_FIRST_NUM=($GENERATE_THREE_NUM   $GENERATE_TWO_NUM)
      FIRST_NUM=${RANGE_FIRST_NUM[$(( RANDOM % ${#RANGE_FIRST_NUM[@]} ))]}
  
      # 第二个数字
      RANGE_SECOND_NUM=($GENERATE_ONE_NUM_FIRST_NUM_NULL_ONETWO ${GENERATE_ONE_NUM_NULL_ZERO}0)
      SECOND_NUM=${RANGE_SECOND_NUM[$(( RANDOM % ${#RANGE_SECOND_NUM[@]} ))]}
  
      # 随机乘除
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
                    # (a op1 b) op2 c 括号优先
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
                        # 收集所有合法因数 >=2 && !=inner
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
                    # a op1 (b op2 c) 括号优先
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
                    # a op1 b op2 c 无括号 先乘除后加减
                    op1_prio=0
                    op2_prio=0
                    [[ $op1 == "*" || $op1 == "/" ]] && op1_prio=1
                    [[ $op2 == "*" || $op2 == "/" ]] && op2_prio=1

                    if (( op1_prio >= op2_prio ));then
                        # 先算左边 a op1 b
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
                        # op2优先级高，先算右边 b op2 c
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
            # 过滤负数结果
            if (( res >= 0 && valid == 1 ));then
                break
            fi
        done
        # 符号替换 *→× /→÷
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
    
    # 输出题目 4列排版
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

# ========================================================

#一、口算(每天20道)
KS_CHENGCHUFA '20'

printf '\n%.0s' {1..2} >>${TMP_Q_DIR}
printf '\n%.0s' {1..2} >>${TMP_A_DIR}

#二、脱式(每天8道)
TUOSHI '2'

printf '\n%.0s' {1..2} >>${TMP_Q_DIR}
printf '\n%.0s' {1..2} >>${TMP_A_DIR}

#三、竖式(每天6道)
SHUSHI '10'


cat ${TMP_Q_DIR} >> ${TMP_ALL_Q_A}
printf '\n%.0s' {1..10} >> ${TMP_ALL_Q_A}
echo "==================================【答案】==================================" >> ${TMP_ALL_Q_A}
cat ${TMP_A_DIR} >> ${TMP_ALL_Q_A}


cat  ${TMP_ALL_Q_A}

rm -f ${TMP_Q_DIR} ${TMP_A_DIR} ${TMP_ALL_Q_A}
