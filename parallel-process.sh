#!/usr/bin/env bash
# usage: ./parallel-process.sh inputDir outputDir
# author: Ranler findfunaax@gmail.com

PARALLEL=4
LOG_FILE=parser.log
OUT_FILE_PREFIX="d_"

# 只处理的文件列表，如果定义此项，则只处理此列表内的文件
FILE_INCLUDE=()
INCLUDE_LOG_FILE=parser_include.log


# 目录中的每个文件$1用以下命令处理，输出到$2中
function parser_sub(){
    #echo $1;sleep 1
}


#=================== Do not Modify ======================

TMP_FILE=/tmp/$$.fifo
TIMEFORMAT="%H:%M:%S %Y-%m-%d"

# 删除错误标识文件
rm -f ${LOG_FILE}

# 创建并发用的管道，关联到文件描述符6上
mkfifo $TMP_FILE
exec 6<>$TMP_FILE
rm -f $TMP_FILE
# 向管道中写入PARALLEL个回车
for((i=0;i<$PARALLEL;i++));
do
    echo
done >&6

#读取目录内的文件到列表
file_num=0
for file in ${1}/*;
do
    if [ -f $file ]; then
	file_array[$file_num]=`basename $file`
	let file_num=$file_num+1
    fi
done
echo "account for $file_num files" >> ${LOG_FILE}

if [ -z $FILE_INCLUDE ]; then 
    #循环并发处理所有文件
    for file in ${file_array[@]};
    do
	read <&6
	{
	    echo "start[$(date +"$TIMEFORMAT")]:$file" >> ${LOG_FILE}
	    parser_sub "$1/$file" "$2/$OUT_FILE_PREFIX$file" &&{
		echo "done [$(date +"$TIMEFORMAT")]:$file" >> ${LOG_FILE}
	    }||{
		echo "error[$(date +"$TIMEFORMAT")]:$file" >> ${LOG_FILE}
	    }
	    echo >&6
	}&
    done
else
    for file in ${FILE_INCLUDE[@]}; do
	if [ -f "$1/$file" ]; then
	    read <&6
	    {
		echo "start[$(date +"$TIMEFORMAT")]:$file" >> ${INCLUDE_LOG_FILE}
		parser_sub "$1/$file" "$2/$OUT_FILE_PREFIX$file" &&{
		    echo "done [$(date +"$TIMEFORMAT")]:$file" >> ${INCLUDE_LOG_FILE}
		}||{
		    echo "error[$(date +"$TIMEFORMAT")]:$file" >> ${INCLUDE_LOG_FILE}
		}
		echo >&6
	}&
	else
	    echo "file not exist:$file" >> ${INCLUDE_LOG_FILE}
	fi
    done
fi


# 等待所有进程结束，关闭管道
wait
exec 6>&-

echo "all done at $(date +"$TIMEFORMAT")" >> ${LOG_FILE}


exit 0
