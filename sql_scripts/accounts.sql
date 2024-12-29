create table if not exists dndx_dwh_dim_accounts_stg_del
(
    account_num varchar
);

-- 3. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
insert into dndx_dwh_dim_accounts_stg_del (account_num)
select account_num
from dndx_stg_accounts;

-- 4. Загрузка в приемник "вставок" на источнике (формат SCD1).
insert into dndx_dwh_dim_accounts (account_num, valid_to, client, create_dt, update_dt)
select stg.account_num
     , stg.valid_to
     , stg.client
     , stg.update_dt
     , null
from dndx_stg_accounts as stg
         left join dndx_dwh_dim_accounts as tgt
                   using (account_num)
where tgt.account_num is null;

-- 5. Обновление в приемнике "обновлений" на источнике (формат SCD1).
update dndx_dwh_dim_accounts
set valid_to  = tmp.valid_to,
    client    = tmp.client,
    create_dt = tmp.create_dt,
    update_dt = tmp.update_dt

from (select stg.account_num,
             stg.valid_to,
             stg.client,
             stg.create_dt,
             stg.update_dt

      from dndx_stg_accounts as stg
               inner join dndx_dwh_dim_accounts as tgt
                          using (account_num)
      where stg.valid_to <> tgt.valid_to
         or stg.client <> tgt.client
         or stg.create_dt <> tgt.create_dt
         or stg.update_dt <> tgt.update_dt) as tmp
where dndx_dwh_dim_accounts.account_num = tmp.account_num;

-- 6. Удаление в приемнике удаленных в источнике записей (формат SCD1).
delete
from dndx_dwh_dim_accounts
where account_num in (select tgt.account_num
                      from dndx_dwh_dim_accounts as tgt
                               left join dndx_dwh_dim_accounts_stg_del as stg
                                         on tgt.account_num = stg.account_num
                      where stg.account_num is null);

drop table dndx_dwh_dim_accounts_stg_del;

