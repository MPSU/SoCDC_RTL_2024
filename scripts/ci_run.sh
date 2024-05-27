#!/bin/bash

# Директория с репозиторием, в который осуществляется пуш.
# Передается раннером, запускающим этот скрипт.
ORIGIN_DIR=$1

# Директория с репозиторием, в котором осуществляется
# тестовый прогон.
# Передается раннером, запускающим этот скрипт.
TEST_DIR=$2

# Директория результата запуска CI.
# Передается раннером, запускающим этот скрипт.
OUT_DIR=$3

# Директория, из которой запускается скрипт.
SCRIPT_DIR=$PWD

# Подготовка тестовой директории:
# 1. удаляем rtl/ в тестовой директории;
# 2. подгружаем rtl/ директории пользователя;
# 3. подгружаем список RTL исходников из директории
#    пользователя (scp скопирует с заменой).
prepare_test_dir() {
    echo "Подготовка тестовой директории"
    # -
    rm -rf $TEST_DIR/rtl
    # -
    scp -r $ORIGIN_DIR/rtl $TEST_DIR
    # -
    scp $ORIGIN_DIR/dv/build/rtl.f $TEST_DIR/dv/build
    scp $ORIGIN_DIR/dv/build/rtl_vhdl.f $TEST_DIR/dv/build
}

# Запуск
# 1. переходим в тестовую директорию;
# 2-3. загружаем ПО;
# 4. запускаем симуляцию;
# 5. возвращаемся в директорию скрипта.
run_test_dir() {
    echo "Запуск тестирования"
    # -
    cd $TEST_DIR/dv/build
    # -
    module purge 2>/dev/null
    module load mentor/QUESTA_VERIFICATION_IP/2020.4_1
    make clean
    make SEED=113355
    # -
    cd $SCRIPT_DIR
}

# Постпроцессинг запуска
# 1. создаем выходную директорию
# 2. если существует лог симуляции - удаляем строчку,
#    где определено зерно, чтобы участники не могли
#    воспроизвести;
# 3. копируем все .log файлы в выходную директорию
# 4. если существуют .txt файлы, копируем и их
proc_test_dir() {
    echo "Выгрузка результатов"
    # -
    rm -rf $OUT_DIR; mkdir $OUT_DIR
    # -
    if [ -e $TEST_DIR/dv/build/out/rtl_run.log ]; then
        sed -i '/sv_seed/d' $TEST_DIR/dv/build/out/rtl_run.log
    fi
    # -
    scp $TEST_DIR/dv/build/out/*.log $OUT_DIR
    # -
    if [ -n "$(find $TEST_DIR/dv/build/out/ -name '*.txt')" ]; then
        scp $TEST_DIR/dv/build/out/*.txt $OUT_DIR
    fi
}

# Запуск
prepare_test_dir
run_test_dir
proc_test_dir
