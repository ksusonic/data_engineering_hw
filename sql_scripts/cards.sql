create table if not exists dndx_dwh_dim_cards_stg_del
(
    card_num varchar
);

-- 3. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
insert into dndx_dwh_dim_cards_stg_del (card_num)
select card_num
from dndx_stg_cards;

-- 4. Загрузка в приемник "вставок" на источнике (формат SCD1).
insert into dndx_dwh_dim_cards (card_num, account_num, create_dt, update_dt)
select stg.card_num
     , stg.account_num
     , stg.update_dt
     , null
from dndx_stg_cards as stg
         left join dndx_dwh_dim_cards as tgt
                   using (card_num)
where tgt.card_num is null;

-- 5. Обновление в приемнике "обновлений" на источнике (формат SCD1).
update dndx_dwh_dim_cards
set account_num = tmp.account_num,
    create_dt   = tmp.create_dt,
    update_dt   = tmp.update_dt

from (select stg.card_num,
             stg.account_num,
             stg.create_dt,
             stg.update_dt

      from dndx_stg_cards as stg
               inner join dndx_dwh_dim_cards as tgt
                          using (card_num)
      where stg.account_num <> tgt.account_num
         or stg.create_dt <> tgt.create_dt
         or stg.update_dt <> tgt.update_dt) as tmp
where dndx_dwh_dim_cards.card_num = tmp.card_num;

-- 6. Удаление в приемнике удаленных в источнике записей (формат SCD1).
delete
from dndx_dwh_dim_cards
where card_num in (select tgt.card_num
                   from dndx_dwh_dim_cards as tgt
                            left join dndx_dwh_dim_cards_stg_del as stg
                                      on tgt.card_num = stg.card_num
                   where stg.card_num is null);

drop table dndx_dwh_dim_cards_stg_del;
