# liteic_master_node_write.sv

#### Описание модуля

`liteic_master_node_write` - модуль, предназначенный для подключения одного Master-а к Slave устройствам согласно заданной матрице связанности (в нашем случае Master связан со всеми Slave устройствам).  В нем формируются сигналы **каналов записи** протокола AXI_Lite. В каждой ноде `liteic_master_node_write` используются модули: 

- [liteic_addr_decoder](./liteic_addr_decoder.md) - декодер адреса
- [liteic_priority_cd](./liteic_priority_cd.md)

#### Таблица 1. Параметры модуля

| Название параметра  | Значение по умолчанию                      | Назначение                                                                     |
|:-|:--------:|:---|
|IC_NUM_SLAVE_SLOTS   |         12                                 | Количество Slave слотов                                                        |                    
|IC_AWADDR_WIDTH      |         32                                 | Ширина шины адреса                                                             | 
|IC_WDATA_WIDTH       |         36                                 | Ширина шины данных и маски                                                     |
|IC_BRESP_WIDTH       |         2                                  | Ширина шины отклика                                                            |
|IC_INVALID_ADDR_RESP |         2                                  | Ширина шины ошибки адресного пространства                                      |
|IC_WR_CONNECTIVITY   | [IC_NUM_SLAVE_SLOTS][IC_NUM_MASTER_SLOTS]  | Матрицы связанности каналов записи                                              |
|IC_SLAVE_REGION_BASE | [AXI_ADDR_WIDTH][IC_NUM_SLAVE_SLOTS]       | Начало адресного пространства каждого из IC_NUM_SLAVE_SLOTS Master интерфейсов | 
|IC_SLAVE_REGION_SIZE | [AXI_ADDR_WIDTH][IC_NUM_SLAVE_SLOTS]       | Размер адресного пространства каждого из IC_NUM_SLAVE_SLOTS Master интерфейсов | 


#### Таблица 2. Порты модуля

| Название сигнала      | Разрядность                           | Назначение                                                                           |
|:-|:--------|:---|
|clk_i                  |     1                                 | Тактовый сигнал                                                                      |                             
|rstn_i                 |     1                                 | Сигнал сброса                                                                        |        
|cbar_w_reqst_rdy_i     |       IC_NUM_SLAVE_SLOTS              | Шина входных сигналов от wr_slv_node_write для формирования сигнала w_ready          | 
|cbar_w_reqst_val_o     |       IC_NUM_SLAVE_SLOTS              | Шина выходных сигналов в wr_slv_node_write для формирования сигнала w_valid          |    
|cbar_w_reqst_data_o    |         IC_WDATA_WIDTH                | Шина выходных сигналов в wr_slv_node_write для формирования сигнала {w_strb, w_data} | 
|cbar_aw_reqst_rdy_i    |       IC_NUM_SLAVE_SLOTS              | Шина входных сигналов от wr_slv_node_write для формирования сигнала aw_ready         |    
|cbar_aw_reqst_val_o    |       IC_NUM_SLAVE_SLOTS              | Шина выходных сигналов в wr_slv_node_write для формирования сигнала aw_valid         |         
|cbar_aw_reqst_data_o   |         IC_WDATA_WIDTH                | Шина адреса в wr_slv_node_write для формирования сигнала aw_addr                     |
|cbar_resp_data_i       | IC_BRESP_WIDTH [IC_NUM_SLAVE_SLOTS]   | Массив шин входных сигналов от wr_slv_node_write для формирования b_resp             |    
|cbar_resp_val_i        |        IC_NUM_SLAVE_SLOTS             | Шина входных сигналов от wr_slv_node_write для формирования сигнала b_walid          |
|cbar_resp_rdy_o        |        IC_NUM_SLAVE_SLOTS             | Шина выходных сигналов в wr_slv_node_write для формирования сигнала b_ready          |    

#### Таблица 3. Интерфейсы модуля

| Название интерфеса      | Modport       | Количество | Назначение                       |
|:-|:--------|:---|:---|
|axi_lite_if              |   sp_write    |     1      | Подключение Master к ноде записи |
