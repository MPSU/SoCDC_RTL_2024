# liteic

#### Структурная схема проекта

![image](./img/readme_interconnect_schem.drawio.svg)

#### Декомпозиция

- [liteic_icon_top](./liteic/liteic_icon_top.md) - топовый уровень интерконнекта
- [liteic_master_node_read](./liteic/liteic_master_node_read.md) - нода Master для чтения информации
- [liteic_master_node_write](./liteic/liteic_master_node_write.md) - нода Master для записи информации
- [liteic_slave_node_read](./liteic/liteic_slave_node_read.md) - нода Slave для передачи информации
- [liteic_slave_node_write](./liteic/liteic_slave_node_write.md) - нода Slave для записи информации
- [liteic_addr_decoder](./liteic/liteic_addr_decoder.md) - декодирование адреса
- [liteic_priority_cd](./liteic/liteic_priority_cd.md) - onehot преобразование и селектор для входных данных

В проекте есть два враппера:

- reg_wrapper - предназначен для получения reg2reg задержек. Данный модуль должен остаться без изменений.
- icon_wrapper - предназначен для фиксирования имен портов после синтеза. Данный модуль должен остаться без изменений.

#### Интерфейс

- [liteic_axi_lite_if](./liteic/liteic_axi_lite_if.md)