# liteic_slave_node_write.sv

#### Описание модуля

`liteic_slave_node_write` - модуль, предназначенный для подключения одного Slave к Master устройствам согласно заданной матрице связанности (в нашем случае Slave связан со всеми Master устройствами). В нем формируются сигналы **каналов записи** протокола AXI_Lite. В каждой ноде `liteic_slave_node_write` используется модуль: 
- [liteic_priority_cd](./liteic_priority_cd.md)


#### Таблица 1. Параметры модуля

| Название параметра  | Значение по умолчанию                      | Назначение                        |
|:-|:--------:|:---|
|IC_NUM_MASTER_SLOTS  |         20                                 | Количество Master слотов          |                    
|IC_AWADDR_WIDTH      |         32                                 | Ширина шины адреса                | 
|IC_WDATA_WIDTH       |         36                                 | Ширина шины данных и маски(strb)  |
|IC_BRESP_WIDTH       |         2                                  | Ширина шины отклика               |
|IC_WR_CONNECTIVITY   | [IC_NUM_SLAVE_SLOTS][IC_NUM_MASTER_SLOTS]  | Матрицы связанности каналов записи |


#### Таблица 2. Порты модуля

| Название сигнала      | Разрядность                              | Назначение                                                                                 |
|:-|:--------|:---|
|clk_i                  |     1                                    | Тактовый сигнал                                                                            |
|rstn_i                 |     1                                    | Сигнал сброса                                                                              |           
|cbar_w_reqst_data_i    |  IC_WDATA_WIDTH [IC_NUM_MASTER_SLOTS]    | Массив шин входных сигналов от wr_mst_node_write для формирования сигнала {w_strb, w_data} |   
|cbar_w_reqst_val_i     |  IC_NUM_MASTER_SLOTS                     | Шина входных сигналов от wr_mst_node_write для формирования сигнала w_valid                |    
|cbar_w_reqst_rdy_o     |  IC_NUM_MASTER_SLOTS                     | Шина выходных сигналов в wr_mst_node_write для формирования сигнала w_ready                |  
|cbar_aw_reqst_data_i   |  IC_AWADDR_WIDTH [IC_NUM_MASTER_SLOTS]   | Массив шин входных сигналов от wr_mst_node_write для формирования сигнала aw_addr          |
|cbar_aw_reqst_val_i    |  IC_NUM_MASTER_SLOTS                     | Шина входных сигналов от wr_mst_node_write для формирования сигнала aw_valid               | 
|cbar_aw_reqst_rdy_o    |  IC_NUM_MASTER_SLOTS                     | Шина выходных сигналов в wr_mst_node_write для формирования сигнала aw_ready               |    
|cbar_resp_rdy_i        |  IC_NUM_MASTER_SLOTS                     | Шина входных сигналов от wr_mst_node_write для формирования сигнала b_ready                |    
|cbar_resp_val_o        |  IC_NUM_MASTER_SLOTS                     | Шина выходных сигналов в wr_mst_node_write для формирования сигнала b_valid                | 
|cbar_resp_data_o       |  IC_BRESP_WIDTH                          | Шина выходных сигналов в wr_mst_node_write для формирования сигнала b_resp                 |    

#### Таблица 3. Интерфейсы модуля

| Название интерфеса      | Modport       | Количество | Назначение                                 |
|:-|:--------|:---|:---|
|axi_lite_if              |   mp_write    |     1      | Подключение Slave устройства к ноде записи |
