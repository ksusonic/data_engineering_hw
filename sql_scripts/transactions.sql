create table if not exists dndx_dwh_dim_transactions_stg_del
(
    trans_id varchar
);

-- 3. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
insert into dndx_dwh_dim_transactions_stg_del (trans_id)
select trans_id
from dndx_stg_transactions;

-- 4. Загрузка в приемник "вставок" на источнике (формат SCD1).
insert into dndx_dwh_dim_transactions (trans_id, trans_date, card_num, oper_type, amt, oper_result, terminal, create_dt,
                                       update_dt)
select stg.trans_id
     , stg.trans_date
     , stg.card_num
     , stg.oper_type
     , stg.amt
     , stg.oper_result
     , stg.terminal
     , stg.update_dt
     , null
from dndx_stg_transactions as stg
         left join dndx_dwh_dim_transactions as tgt
                   using (trans_id)
where tgt.trans_id is null;

-- 5. Обновление в приемнике "обновлений" на источнике (формат SCD1).
update dndx_dwh_dim_transactions
set trans_date  = tmp.trans_date,
    card_num    = tmp.card_num,
    oper_type   = tmp.oper_type,
    amt         = tmp.amt,
    oper_result = tmp.oper_result,
    terminal    = tmp.terminal,
    create_dt   = tmp.create_dt,
    update_dt   = tmp.update_dt

from (select stg.trans_id,
             stg.trans_date,
             stg.card_num,
             stg.oper_type,
             stg.amt,
             stg.oper_result,
             stg.terminal,
             stg.create_dt,
             stg.update_dt

      from dndx_stg_transactions as stg
               inner join dndx_dwh_dim_transactions as tgt
                          using (trans_id)
      where stg.trans_date <> tgt.trans_date
         or stg.card_num <> tgt.card_num
         or stg.oper_type <> tgt.oper_type
         or stg.amt <> tgt.amt
         or stg.oper_result <> tgt.oper_result
         or stg.terminal <> tgt.terminal
         or stg.create_dt <> tgt.create_dt
         or stg.update_dt <> tgt.update_dt) as tmp
where dndx_dwh_dim_transactions.trans_id = tmp.trans_id;

-- 6. Удаление в приемнике удаленных в источнике записей (формат SCD1).
delete
from dndx_dwh_dim_transactions
where trans_id in (select tgt.trans_id
                   from dndx_dwh_dim_transactions as tgt
                            left join dndx_dwh_dim_transactions_stg_del as stg
                                      on tgt.trans_id = stg.trans_id
                   where stg.trans_id is null);

drop table dndx_dwh_dim_transactions_stg_del;
