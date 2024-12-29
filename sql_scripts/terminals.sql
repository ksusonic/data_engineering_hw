create table if not exists dndx_dwh_dim_terminals_stg_del
(
    terminal_id varchar
);

-- 3. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
insert into dndx_dwh_dim_terminals_stg_del (terminal_id)
select terminal_id
from dndx_stg_terminals;

-- 4. Загрузка в приемник "вставок" на источнике (формат SCD1).
insert into dndx_dwh_dim_terminals (terminal_id, terminal_type, terminal_city, terminal_address, create_dt, update_dt)
select stg.terminal_id
     , stg.terminal_type
     , stg.terminal_city
     , stg.terminal_address
     , stg.update_dt
     , null
from dndx_stg_terminals as stg
         left join dndx_dwh_dim_terminals as tgt
                   using (terminal_id)
where tgt.terminal_id is null;

-- 5. Обновление в приемнике "обновлений" на источнике (формат SCD1).
update dndx_dwh_dim_terminals
set terminal_type    = tmp.terminal_type,
    terminal_city    = tmp.terminal_city,
    terminal_address = tmp.terminal_address,
    create_dt        = tmp.create_dt,
    update_dt        = tmp.update_dt

from (select stg.terminal_id,
             stg.terminal_type,
             stg.terminal_city,
             stg.terminal_address,
             stg.create_dt,
             stg.update_dt

      from dndx_stg_terminals as stg
               inner join dndx_dwh_dim_terminals as tgt
                          using (terminal_id)
      where stg.terminal_type <> tgt.terminal_type
         or stg.terminal_city <> tgt.terminal_city
         or stg.terminal_address <> tgt.terminal_address
         or stg.create_dt <> tgt.create_dt
         or stg.update_dt <> tgt.update_dt) as tmp
where dndx_dwh_dim_terminals.terminal_id = tmp.terminal_id;

-- 6. Удаление в приемнике удаленных в источнике записей (формат SCD1).
delete
from dndx_dwh_dim_terminals
where terminal_id in (select tgt.terminal_id
                      from dndx_dwh_dim_terminals as tgt
                               left join dndx_dwh_dim_terminals_stg_del as stg
                                         on tgt.terminal_id = stg.terminal_id
                      where stg.terminal_id is null);

drop table dndx_dwh_dim_terminals_stg_del;
