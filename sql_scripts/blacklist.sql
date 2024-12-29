create table if not exists dndx_dwh_dim_blacklist_stg_del
(
    passport varchar
);

-- 3. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
insert into dndx_dwh_dim_blacklist_stg_del (passport)
select passport
from dndx_stg_blacklist;

-- 4. Загрузка в приемник "вставок" на источнике (формат SCD1).
insert into dndx_dwh_dim_blacklist (passport, entry_dt, create_dt, update_dt)
select stg.passport
     , stg.entry_dt
     , stg.update_dt
     , null
from dndx_stg_blacklist as stg
         left join dndx_dwh_dim_blacklist as tgt
                   using (passport)
where tgt.passport is null;

-- 5. Обновление в приемнике "обновлений" на источнике (формат SCD1).
update dndx_dwh_dim_blacklist
set entry_dt  = tmp.entry_dt,
    create_dt = tmp.create_dt,
    update_dt = tmp.update_dt

from (select stg.passport,
             stg.entry_dt,
             stg.create_dt,
             stg.update_dt

      from dndx_stg_blacklist as stg
               inner join dndx_dwh_dim_blacklist as tgt
                          using (passport)
      where stg.entry_dt <> tgt.entry_dt
         or stg.create_dt <> tgt.create_dt
         or stg.update_dt <> tgt.update_dt) as tmp
where dndx_dwh_dim_blacklist.passport = tmp.passport;

-- 6. Удаление в приемнике удаленных в источнике записей (формат SCD1).
delete
from dndx_dwh_dim_blacklist
where passport in (select tgt.passport
                   from dndx_dwh_dim_blacklist as tgt
                            left join dndx_dwh_dim_blacklist_stg_del as stg
                                      on tgt.passport = stg.passport
                   where stg.passport is null);

drop table dndx_dwh_dim_blacklist_stg_del;
