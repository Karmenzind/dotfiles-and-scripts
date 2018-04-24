#!/usr/bin/env bash
# 用于管理Docker服务
# 隐去部分本地内容

RUN_ENV=''    

SHELL_FOLDER=$(cd `dirname ${0}`; pwd)
LOG_PATH='/var/log/servers'

declare -A EXISTED_CONTAINERS
declare -A CONTAINERS_TO_START


# 备用，颜色+加粗
bold='\033[1m'
origin='\033[0m'
black='\E[30;1m'
red='\E[31;1m'
green='\E[32;1m'
yellow='\E[33;1m'
blue='\E[34;1m'
magenta='\E[35;1m'
cyan='\E[36;1m'
white='\E[37;1m'

cut_off="----------------------------------------------"

# -----------------------------------------------------------------------------

# Color-echo. (http://www.tldp.org/LDP/abs/html/colorizing.html#COLORECHO)
# Argument $1 = message
# Argument $2 = color
function cecho {
    echo -e "${2:-${bold}}${1}" 
    tput sgr0                        # Reset to normal.
}  

# 帮助信息
function help {
    echo -e "
manage.sh   

${bold}NAME${origin}
        ${0} - Docker项目服务管理脚本

${bold}SYNOPSIS${origin}
        ${0} action [project] [options]
    
        ${bold}action${origin}:
            start               启动服务            
            stop                停止服务            
            restart             重启服务            
            status              服务状态            
            help(-h/--help)     查看帮助          
    
        ${bold}project${origin}:
            项目名称，用于获取配置，例如{project}
                                            
${bold}OPTIONS${origin}
        --image              
            Docker完整镜像名称 {registry/image:tag}

${bold}EXAMPLES${origin}
        查看帮助            
            ${0} --help
        指定镜像重启项目    
            ${0} restart {project} --image {registry/image:tag}
        查看运行状态        
            ${0} status {project} 

"
}

# 启动所有服务
function start {
    for port in ${!CONTAINERS_TO_START[@]}; do
        container=${CONTAINERS_TO_START[${port}]}

        docker run --restart="always" -d            \
            -p ${port}:${port}                      \
            -v ${LOG_PATH}:${LOG_PATH}              \
            -e "RUN_ENV=${RUN_ENV}"                 \
            -e "PROJECT_NAME=${PROJECT_NAME}"       \
            -e "HTTP_PORT=${port}"                  \
            ${DOCKER_EXTRA_PARAMS}                  \
            --name ${container}                     \
            $DOCKER_IMAGE 
        if (( "$?" != 0 )); then
            cecho "Failed to start ${container}" ${red}
            exit -1
        fi
        echo "Container <${container}> started."
    done
}

# 停止所有服务
function stop {
    for port in ${!EXISTED_CONTAINERS[@]}; do
        container=${EXISTED_CONTAINERS[${port}]}
        docker rm -f ${container}
        echo "Container <${container}> has been stopped and deleted."
        CONTAINERS_TO_START[${port}]=${container}
    done
    unset EXISTED_CONTAINERS 
}

# 查看服务状态
function status {
    not_running=''
    for port in ${!EXISTED_CONTAINERS[@]}; do
        container=${EXISTED_CONTAINERS[${port}]}
        [[ -z "`docker ps -q -f name=${container}`" ]] && not_running="${not_running}${container} "

        cecho "==> ${container} <==\n" 
        docker ps -a -f name=${container} --format 'table {{.ID}}\t{{.Ports}}\t{{.Status}}\t{{.Command}}'
        echo -e "\n- logs:"
        docker logs ${container} -t 
        echo
    done
    [[ -n "${not_running}" ]] && cecho "* Not running: ${not_running}" ${red}
    if [[ ${#CONTAINERS_TO_START[@]} > 0 ]]; then
        for port in ${!CONTAINERS_TO_START[@]}; do
            cecho "* No container for port: ${port}." ${red}
        done
    fi
    echo -e "\nFor more details, run:
    docker logs -f [container_name_or_id]
    tail -f ${LOG_PATH}/[project_dir]/*"
}

# 获取配置服务器地址
function get_configure_server_url {
    ...
}

# 根据名称获取配置
# Argument $1 = Config key (e.g. 'DATA_BASE')
function get_config {
    echo "$CONFIG_RAW" | jq ".${1}?" --raw-output
}

# 准备工作，获取一些特定配置，供其他使用
function prepare {
    CONFIG_FILE="/tmp/${PROJECT_NAME}_CONFIG.json"  # 配置文件保存地址
    CONFIG_RAW=`curl -s $(get_configure_server_url) | tee ${CONFIG_FILE} | jq '.data?'`
    if [[ -z "$CONFIG_RAW" ]]; then
        echo "Failed to fetch config." 
        exit -1
    fi

    HTTP_PORTS=`get_config 'HTTP_PORTS' | tr ';' ' '`
    DOCKER_EXTRA_PARAMS=`get_config 'DOCKER_EXTRA_PARAMS'`
    [[ -z "$DOCKER_IMAGE" ]] && DOCKER_IMAGE=`get_config 'DOCKER_IMAGE'`

    for port in $HTTP_PORTS; do
        container="${PROJECT_NAME}_${port}"
        is_existed=`docker ps -a -q -f name=${container}`
        if [[ -n "$is_existed" ]]; then
            EXISTED_CONTAINERS[${port}]=${container}
        else
            CONTAINERS_TO_START[${port}]=${container}
        fi
    done
}

# 打印基本信息
function print_base_infos {
    cecho "                                                  " 
    # cecho "\n################# BASE INFO ##################\n" 
    cecho "- Project:        ${PROJECT_NAME}                 " 
    cecho "- Action:         ${ACTION}                       " 
    cecho "- Docker image:   ${DOCKER_IMAGE}                 " 
    cecho "- HTTP ports:     ${HTTP_PORTS}                   " 
    cecho "- Existing Containers:                            " 
    for port in ${!EXISTED_CONTAINERS[@]}; do
        cecho "       ${port}: ${EXISTED_CONTAINERS[${port}]}" 
    done
    cecho "- Need to create:                                 " 
    for port in ${!CONTAINERS_TO_START[@]}; do
        cecho "      ${port}: ${CONTAINERS_TO_START[${port}]}" 
    done
    cecho "\n${cut_off}" 
    #cecho "\n##############################################\n" 
    cecho "                                                  " 
}

# 解析输入参数
function parse_input_params {
    case ${1} in
        -h|--help)
            help
            exit    ;;
    esac

    if [[ ${#} -ge 2 ]] && [[ $((${#}%2)) = 0 ]]; then
        ACTION=$1
        PROJECT_NAME=$2

        if [[ ${#} > 2 ]]; then  # 关键字参数
            shift; shift

            case ${1} in 
                --image)    
                    if [[ -z "`docker images ${2} -q`" ]]; then 
                        cecho "Unable to find image locally: ${2}" ${red}
                        exit -1
                    fi
                    DOCKER_IMAGE=${2}
                    shift; shift                        ;;
                *)          
                    help; exit -1                       ;;
            esac
        fi

    else
        help
        exit -1
    fi
}

# 执行操作
function do_action()
{
    case $ACTION in
        start)      start           ;;
        stop)       stop            ;;
        restart)    stop; start     ;;
        status)     status          ;;
        *)          help            ;;
    esac
}

# -----------------------------------------------------------------------------

clear
parse_input_params $@ && prepare && print_base_infos && do_action 
cecho "\n${cut_off}\nDONE :)\n" 

