#!/bin/echo It's a subscript

##.############################################################################.
##! Copyright (C) Марков Евгений 2022
##!
##! \file   em_lib_keystroke.sh
##! \author Марков Евгений <upirtf@gmail.com>
##! \date   2022-09-15 22:47
##!
##! \brief Библиотека для создания скрипта, управляемого через повторные
##!        запуски.
##!
##! Скрипт позволяет выполнять разные действия (команды), в зависимости от того,
##! сколько раз он был запущен в течении короткого промежутка времени. Например,
##! если скрипт был вызван по одиночному или двойному или тройному нажатию
##! Shortcat-а.
##|
##'############################################################################'


##.=======================================================================.
##! \brief Сгенерировать случайное десятичное число.
##!
##! \param $1     - случайная строка.
##!
##! \return  -  stdout :
##!                 случайное десятичное число.
##| 
##'======================================================================='
em_lib_keystroke_rnd_gen () {

    local hsh="0x$(echo "${1}"|sha1sum)"
    hsh="${hsh:0:15}"
    printf "%016d" "${hsh}"
}
#export -f em_lib_keystroke_rnd_gen



##.=======================================================================.
##! \brief Посчитать сумму маркеров.
##!
##! \param $1 - маркер первого запуска;
##! \param $2 - маркер второго запуска;
##! \param $3 - маркер третьего запуска.
##|
##'======================================================================='
em_lib_keystroke_markers_sum () {
    local sum=0
    local el
    
    for el in ${@}; do
        let "sum = sum + $(echo "${el}"| sed -e 's/^0*//g')"
    done
    echo "${sum}"
}
#export -f em_lib_keystroke_markers_sum



##.=======================================================================.
##! \brief Получить список установленных маркеров.
##!
##! \param $1 - pid или marker
##! \param $2 - маркер первого запуска;
##! \param $3 - маркер второго запуска;
##! \param $4 - маркер третьего запуска.
##|
##'======================================================================='
em_lib_keystroke_existing_markers () {
    local obj="\\1"
    local two=
    local three=

    [ "${1}" != pid ] && obj="\\2"
    [ -n "${3}" ] && two="\\|${3}"
    [ -n "${4}" ] && three="\\|${4}"

    ps -axo pid:1,args| \
        sed -n "s/^\([0-9]\+\)[ \t]\+sleep [0-9]\+\.[0-9]\{2\}`
                  `\(${2}${two}${three}\)\$/${obj}/gp"
}
#export -f em_lib_keystroke_existing_markers



##.=======================================================================.
##! \brief Посчитать сумму установленных маркеров.
##!
##! \param $1 - маркер первого запуска;
##! \param $2 - маркер второго запуска;
##! \param $3 - маркер третьего запуска.
##|
##'======================================================================='
em_lib_keystroke_existing_markers_sum () {
    local lst

    lst=$(em_lib_keystroke_existing_markers marker "${1}" "${2}" "${3}")

    em_lib_keystroke_markers_sum ${lst}
}
#export -f em_lib_keystroke_existing_markers_sum



##.=======================================================================.
##! \brief Удалить установленные маркеры.
##!
##! \param $1 - маркер первого запуска;
##! \param $2 - маркер второго запуска;
##! \param $3 - маркер третьего запуска.
##|
##'======================================================================='
em_lib_keystroke_clean (){
    
    local pids="$(em_lib_keystroke_existing_markers pid `
                                                   `"${1}" "${2}" "${3}")"

    if [ -n "${pids}" ];then
        while  IFS= read -r p; do
            kill "${p}"
        done <<< "${pids}"
        return 0
    else
        return 1
    fi
}
#export -f em_lib_keystroke_clean



##.=======================================================================.
##! \brief Основнрй цикл.
##!
##! \param $1 - время жизни маркера первого запуска;
##! \param $2 - маркер первого запуска;
##! \param $3 - время жизни маркера второго запуска;
##! \param $4 - маркер второго запуска;
##! \param $5 - время жизни маркера третьего запуска;
##! \param $6 - маркер третьего запуска.
##! \param $7 - время жизни маркера блокировки;
##! \param $8 - маркер блокировки.
##! \param $9 - время жизни защитного интервала.
##!
##! \return   - return code :
##!                 0 - установлен очередной маркер запуска;
##!                 1 - фиксирован одиночный запуск;
##!                 2 - фиксирован двойной запуск;
##!                 3 - фиксирован тройной запуск;
##!                10 - избыточный запуск;
##!                11 - ошибочное состояние: отсутствуют маркеры запуска
##!                                          после защитного интервала
##!                                          в первом запуске;
##!                12 - ошибочное состояние: неверная сумма маркеров
##!                                          запуска после защитного
##!                                          интервала в первом запуске;
##!                14 - ошибочное состояние: неверная сумма маркеров
##!                                          запуска.
##!                15 - состояние блокировки.
##|
##'======================================================================='
em_lib_keystroke_main (){

    local sum rv cn
    local sum1th=$(em_lib_keystroke_markers_sum ${2})
    local sum2th=$(em_lib_keystroke_markers_sum ${2} ${4})
    local sum3th=no
    [ -n "${6}" ] && sum3th=$(em_lib_keystroke_markers_sum ${2} ${4} ${6})


    sum=$(em_lib_keystroke_existing_markers_sum ${2} ${4} ${6})

    case ${sum} in
        "${sum1th}")
            setsid -w sleep "${3}${4}" &
            ;;
        "${sum2th}")
            if [ -n "${6}" ];then
                setsid -w sleep "${5}${6}" &
            else
                em_lib_keystroke_clean "${2}" "${4}" "${6}"
                return 10
            fi
            ;;
        "${sum3th}")
            # ошибочное состояние: избыточный запуск (четвертый)
            em_lib_keystroke_clean "${2}" "${4}" "${6}"
            return 10
            ;;
        0)
            if [ -z "$(em_lib_keystroke_existing_markers pid ${8})" ]
            then
                setsid -w sleep "${1}${2}" &
                setsid -w sleep "${7}${8}" &

                sleep ${9}

                sum=$(em_lib_keystroke_existing_markers_sum "${2}" "${4}" "${6}")

                case ${sum} in
                    "${sum1th}")
                        echo "em_lib_keystroke_main: rv = 1"
                        rv=1
                        ;;
                    "${sum2th}")
                        echo "em_lib_keystroke_main: rv = 2"
                        rv=2
                        ;;
                    "${sum3th}")
                        echo "em_lib_keystroke_main: rv = 3"
                        rv=3
                        ;;
                    0)
                        # ошибочное состояние: отсутствуют маркеры запуска
                        # после защитного интервала в первом запуске.
                        em_lib_keystroke_clean "${2}" "${4}" "${6}"
                        return 11
                        ;;
                    *)
                        # ошибочное состояние: неверная сумма маркеров запуска
                        # после защитного интервала в первом запуске
                        em_lib_keystroke_clean "${2}" "${4}" "${6}"
                        return 12
                        ;;
                esac

                em_lib_keystroke_clean "${2}" "${4}" "${6}"
                return ${rv}

            else
                em_lib_keystroke_clean "${8}"
                setsid -w sleep "${7}${8}" &
                return 15
            fi
            ;;
        *)
            # ошибочное состояние: неверная сумма маркеров запуска во время
            # при очередном запуске
            em_lib_keystroke_clean "${2}" "${4}" "${6}"
            return 14
            ;;
    esac

    return 0
}    
#export -f em_lib_keystroke_main
