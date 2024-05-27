# liteic_master_node_read.sv

#### Описание модуля

`liteic_master_node_read` - модуль, предназначенный для подключения одного Master-а к Slave устройствам согласно заданной матрице связанности (в нашем случае Master связан со всеми Slave устройствам). В нем формируются сигналы **каналов чтения** протокола AXI_Lite. В каждой ноде `liteic_master_node_read` используются модули:
- [liteic_addr_decoder](./liteic_addr_decoder.md) - декодер адреса
- [liteic_priority_cd](./liteic_priority_cd.md) 

#### Таблица 1. Параметры модуля

| Название параметра  | Значение по умолчанию                      | Назначение                                                                     |
|:-|:--------:|:---|
|IC_NUM_SLAVE_SLOTS   |         12                                 | Количество Slave слотов                                                        |    
|IC_ARADDR_WIDTH      |         32                                 | Шина адреса данных                                                             |
|IC_RDATA_WIDTH       |         34                                 | Шина данных и отклика                                                          |
|IC_INVALID_ADDR_RESP |         1                                  | Ширина шины ошибки адресного пространства                                      |
|IC_RD_CONNECTIVITY   | [IC_NUM_SLAVE_SLOTS][IC_NUM_MASTER_SLOTS]  | Матрицы связанности каналов чтения                                              |
|IC_SLAVE_REGION_BASE | [AXI_ADDR_WIDTH][IC_NUM_SLAVE_SLOTS]       | Начало адресного пространства каждого из IC_NUM_SLAVE_SLOTS Master интерфейсов | 
|IC_SLAVE_REGION_SIZE | [AXI_ADDR_WIDTH][IC_NUM_SLAVE_SLOTS]       | Размер адресного пространства каждого из IC_NUM_SLAVE_SLOTS Master интерфейсов |                             

#### Таблица 2. Порты модуля

| Название сигнала      | Разрядность                                | Назначение                                                                            |
|:-|:--------|:---|
|clk_i                  |     1                                      | Тактовый сигнал                                                                       |
|rstn_i                 |     1                                      | Сигнал сброса                                                                         |           
|cbar_reqst_rdy_i       |     IC_NUM_SLAVE_SLOTS                     | Шина входных сигналов от rd_slv_node_read для формирования сигнала ar_ready           |   
|cbar_reqst_val_o       |     IC_NUM_SLAVE_SLOTS                     | Шина выходных сигналов в rd_slv_node_read для формирования сигнала ar_valid           |    
|cbar_reqst_data_o      |     IC_ARADDR_WIDTH                        | Шина адреса данных в rd_slv_node_read для формирования ar_addr                        |     
|cbar_resp_data_i       |     IC_RDATA_WIDTH [IC_NUM_SLAVE_SLOTS]  | Массив шин входных данных от rd_slv_node_read для формирования {r_data, r_resp}         |    
|cbar_resp_val_i        |     IC_NUM_SLAVE_SLOTS                     | Шина входных сигналов готовности от rd_slv_node_read для формирования сигнала r_valid | 
|cbar_resp_rdy_o        |     IC_NUM_SLAVE_SLOTS                     | Шина выходных сигналов в rd_slv_node_read для формирования r_ready                    |    

#### Таблица 3. Интерфейсы модуля

| Название интерфеса      | Modport      | Количество | Назначение                                                           |
|:-|:--------|:---|:---|
|axi_lite_if              |   sp_read    |     1      | Подключение Master к ноде чтения (подключаются только каналы чтения) |
