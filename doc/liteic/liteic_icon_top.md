# liteic_icon_top.sv

#### Описание модуля

`liteic_icon_top` — верхнеуровневый модуль интерконнекта. Предназначен для разделения интерфейсов AXI-Lite с помощью `modport` sp и `modport` mp на ноды с соответствующим каналом, который зависит от типа ноды (mst/slv) и канала (read/write). В модуле производится инстанцирование нод и коммутация между ними в соответствии с матрицей связанности: 
- [liteic_master_node_read](./liteic_master_node_read.md) — нода Master для чтения данных из Slave устройств
- [liteic_master_node_write](./liteic_master_node_write.md) — нода Master для записи данных в Slave устройства
- [liteic_slave_node_read](./liteic_slave_node_read.md) — нода чтения данных из Slave в Master устройства
- [liteic_slave_node_write](./liteic_slave_node_write.md) — нода записи данных в Slave из Master устройств

#### Таблица 1. Параметры модуля

| Название параметра  | Значение по умолчанию                      | Назначение                                                                     |
|:-|:--------:|:---|
|IC_NUM_MASTER_SLOTS  |         20                                 | Количество Master слотов                                                       |
|IC_NUM_SLAVE_SLOTS   |         12                                 | Количество Slave слотов                                                        |  
|AXI_ADDR_WIDTH       |         32                                 | Ширина шины адреса                                                             | 
|AXI_DATA_WIDTH       |         32                                 | Ширина шины данных                                                             |    
|AXI_RESP_WIDTH       |         2                                  | Ширина шины отклика                                                            |
|IC_ARADDR_WIDTH      |         32                                 | Ширина шины адреса                                                             |
|IC_RDATA_WIDTH       |         34                                 | Ширина шины данных и отклика                                                   |
|IC_AWADDR_WIDTH      |         32                                 | Ширина шины адреса                                                             |
|IC_WDATA_WIDTH       |         36                                 | Ширина шины данных и маски (strb)                                              |
|IC_BRESP_WIDTH       |         2                                  | Ширина шины отклика                                                            |
|IC_RD_CONNECTIVITY   | [IC_NUM_SLAVE_SLOTS][IC_NUM_MASTER_SLOTS]  | Матрицы связанности каналов чтения                                             |  
|IC_WR_CONNECTIVITY   | [IC_NUM_SLAVE_SLOTS][IC_NUM_MASTER_SLOTS]  | Матрицы связанности каналов записи                                             |  
|IC_SLAVE_REGION_BASE | [AXI_ADDR_WIDTH][IC_NUM_SLAVE_SLOTS]       | Начало адресного пространства каждого из IC_NUM_SLAVE_SLOTS Master интерфейсов | 
|IC_SLAVE_REGION_SIZE | [AXI_ADDR_WIDTH][IC_NUM_SLAVE_SLOTS]       | Размер адресного пространства каждого из IC_NUM_SLAVE_SLOTS Master интерфейсов | 

#### Таблица 2. Порты модуля

| Название сигнала      | Разрядность  | Назначение      |
|:-|:--------|:---|
|clk_i                  |     1        | Тактовый сигнал |                                                                                    
|rstn_i                 |     1        | Сигнал сброса   |                    

#### Таблица 3. Интерфейсы модуля

| Название интерфеса      | Modport | Количество | Назначение                         |
|:-|:--------|:---|:---|
|axi_lite_if              |   sp    |     1      | Подключение Master к интерконнекту |
|axi_lite_if              |   mp    |     1      | Подключение Slave к интерконнекту  |
