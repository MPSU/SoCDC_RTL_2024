# liteic_slave_node_read.sv

#### Описание модуля

`liteic_slave_node_read` - модуль, предназначенный для подключения одного Slave к Master устройствам согласно заданной матрице связанности (в нашем случае Slave связан со всеми Master устройствами). В нем формируются сигналы **каналов чтения** протокола AXI_Lite. В каждой ноде `liteic_slave_node_read` используется модуль:
- [liteic_priority_cd](./liteic_priority_cd.md)  

#### Таблица 1. Параметры модуля

| Название параметра  | Значение по умолчанию                      | Назначение                        |
|:-|:--------:|:---|
|IC_NUM_MASTER_SLOTS  |         20                                 | Количество Master слотов          |                    
|IC_ARADDR_WIDTH      |         32                                 | Ширина шины адреса для чтения     |
|IC_RDATA_WIDTH       |         34                                 | Ширина шины данных и отклика      |
|IC_RD_CONNECTIVITY   | [IC_NUM_SLAVE_SLOTS][IC_NUM_MASTER_SLOTS]  | Матрицы связанности каналов чтения | 


#### Таблица 2. Порты модуля

| Название сигнала      | Разрядность                              | Назначение                                                                            |
|:-|:--------|:---|
|clk_i                  |     1                                    | Тактовый сигнал                                                                       |
|rstn_i                 |     1                                    | Сигнал сброса                                                                         |           
|cbar_reqst_data_i      |  IC_ARADDR_WIDTH [IC_NUM_MASTER_SLOTS]   | Массив шин входных сигналов от rd_mst_node_read для формирования сигнала ar_addr      |   
|cbar_reqst_val_i       |  IC_NUM_MASTER_SLOTS                     | Шина входных сигналов от rd_mst_node_read для формирования сигнала ar_valid           |    
|cbar_reqst_rdy_o       |  IC_NUM_MASTER_SLOTS                     | Шина выходных сигналов для rd_mst_node_read для формирования сигнала ar_ready         |     
|cbar_resp_rdy_i        |  IC_NUM_MASTER_SLOTS                     | Шина входных сигналов от rd_mst_node_read для формирования сигнала r_ready            |    
|cbar_resp_val_o        |  IC_NUM_MASTER_SLOTS                     | Шина выходных сигналов для rd_mst_node_read для формирования сигнала r_valid          | 
|cbar_resp_data_o       |  IC_RDATA_WIDTH                          | Шина выходных сигналов в rd_mst_node_read для формирования сигнала {r_data, r_resp}   |    

#### Таблица 3. Интерфейсы модуля

| Название интерфеса      | Modport      | Количество | Назначение                                 |
|:-|:--------|:---|:---|
|axi_lite_if              |   mp_read    |     1      | Подключение Slave устройства к ноде чтения |
