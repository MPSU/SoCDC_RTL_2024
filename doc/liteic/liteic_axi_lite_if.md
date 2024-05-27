# axi_lite_if.sv

#### Описание интерфейса

Интерфейс `axi_lite_if` основан на спецификации AXI4_lite. В данном проекте в каналы ar и aw были добавлены сигналы приоритета ar_qos и aw_qos.

#### Таблица 1. Параметры интерфейса

| Название параметра  | Значение по умолчанию      | Назначение                           |
|:-|:--------:|:---|
|ADDR_WIDTH           |         32                 | Ширина шины адреса                   |
|DATA_WIDTH           |         32                 | Количество регионов                  |                    
|RESP_WIDTH           |         1                  | Адрес начала адресного пространства  | 
|STRB_WIDTH           |   (DATA_WIDTH + 7) / 8     | Размер адресного пространства        |                                

#### Таблица 2. Порты интерфейса

| Название сигнала | Разрядность         | Назначение                                                             |
|:-|:--------|:---| 
|ar_addr           |    ADDR_WIDTH       | Адрес чтения                                                           |
|ar_qos            |         4           | Сигнал приоритета транзакции                                           |
|ar_valid          |         1           | Сигнал указывает на актуальность адреса                                |
|ar_ready          |         1           | Сигнал готовности Slave принять адрес                                  |
|r_data            |     DATA_WIDTH      | Данные от Slave                                                        |
|r_resp            |     RESP_WIDTH      | Сигнал указывает на статус канала чтения                               |
|r_valid           |         1           | Сигнал указывает на актуальность данных                                |
|r_ready           |         1           | Сигнал готовности Master принять данные                                |
|aw_addr           |     ADDR_WIDTH      | Адрес записи                                                           |
|aw_qos            |          4          | Сигнал приоритета транзакции                                           |
|aw_valid          |          1          | Сигнал указывает на наличие актуального адреса записи                  |
|aw_ready          |          1          | Сигнал указывает что Slave устройство готово принять адрес             |
|w_data            |      DATA_WIDTH     | Данные для записи                                                      |
|w_strb            |      STRB_WIDTH     | Сигнал указывает какие байты содержат актуальные данные                |
|w_valid           |          1          | Сигнал указывает на наличие актуальных данных                          |
|w_ready           |          1          | Сигнал указывает, что Slave устройство может принять данные            |
|b_resp            |      RESP_WIDTH     | Сигнал указывает на статус транзакции                                  |
|b_valid           |          1          | Сигнал указывает на актуальность статуса записи                        |
|b_ready           |          1          | Сигнал указывает что Slave устройство готово принять ответ от ведомого |

#### Таблица 3. Modport

| Название сигнала | Направление sp| Направление mp  | Направление sp_read | Направление sp_write | Направление mp_read | Направление mp_write |
|:-|:--------|:---|:---|:---|:---| :---|
|ar_addr           | input         | output          | input               |   -                  | output              |   -                  |  
|ar_qos            | input         | output          | input               |   -                  | output              |   -                  |
|ar_valid          | input         | output          | input               |   -                  | output              |   -                  |
|ar_ready          | output        | input           | output              |   -                  | input               |   -                  |
|r_data            | output        | input           | output              |   -                  | input               |   -                  |
|r_resp            | output        | input           | output              |   -                  | input               |   -                  |
|r_valid           | output        | input           | output              |   -                  | input               |   -                  |
|r_ready           | input         | output          | input               |   -                  | output              |   -                  |
|aw_addr           | input         | output          |   -                 | input                |   -                 | output               |
|aw_qos            | input         | output          |   -                 | input                |   -                 | output               |
|aw_valid          | input         | output          |   -                 | input                |   -                 | output               |
|aw_ready          | output        | input           |   -                 | output               |   -                 | input                |
|w_data            | input         | output          |   -                 | input                |   -                 | output               |
|w_strb            | input         | output          |   -                 | input                |   -                 | output               |
|w_valid           | input         | output          |   -                 | input                |   -                 | output               |
|w_ready           | output        | input           |   -                 | output               |   -                 | input                |
|b_resp            | output        | input           |   -                 | output               |   -                 | input                |
|b_valid           | output        | input           |   -                 | output               |   -                 | input                |
|b_ready           | input         | output          |   -                 | input                |   -                 | output               |