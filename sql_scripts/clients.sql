create table if not exists dndx_dwh_dim_clients_stg_del
(
    client_id varchar
);

-- 3. Захват в стейджинг ключей из источника полным срезом для вычисления удалений.
insert into dndx_dwh_dim_clients_stg_del (client_id)
select client_id
from dndx_stg_clients;

-- 4. Загрузка в приемник "вставок" на источнике (формат SCD1).
insert into dndx_dwh_dim_clients (client_id, first_name, last_name, patronymic, date_of_birth, phone, passport_num,
                                  passport_valid_to, create_dt, update_dt)
select stg.client_id
     , stg.first_name
     , stg.last_name
     , stg.patronymic
     , stg.date_of_birth
     , stg.phone
     , stg.passport_num
     , stg.passport_valid_to
     , stg.update_dt
     , null
from dndx_stg_clients as stg
         left join dndx_dwh_dim_clients as tgt
                   using (client_id)
where tgt.client_id is null;

-- 5. Обновление в приемнике "обновлений" на источнике (формат SCD1).
update dndx_dwh_dim_clients
set first_name        = tmp.first_name
  , last_name         = tmp.last_name
  , patronymic        = tmp.patronymic
  , date_of_birth     = tmp.date_of_birth
  , phone             = tmp.phone
  , passport_num      = tmp.passport_num
  , passport_valid_to = tmp.passport_valid_to
  , update_dt         = tmp.update_dt
from (select stg.client_id
           , stg.first_name
           , stg.last_name
           , stg.patronymic
           , stg.date_of_birth
           , stg.phone
           , stg.passport_num
           , stg.passport_valid_to
           , stg.update_dt
      from dndx_stg_clients as stg
               inner join dndx_dwh_dim_clients as tgt
                          using (client_id)
      where stg.first_name <> tgt.first_name
         or (stg.first_name is null and tgt.first_name is not null)
         or (stg.first_name is not null and tgt.first_name is null)
         or stg.last_name <> tgt.last_name
         or (stg.last_name is null and tgt.last_name is not null)
         or (stg.last_name is not null and tgt.last_name is null)
         or stg.patronymic <> tgt.patronymic
         or (stg.patronymic is null and tgt.patronymic is not null)
         or (stg.patronymic is not null and tgt.patronymic is null)
         or stg.date_of_birth <> tgt.date_of_birth
         or (stg.date_of_birth is null and tgt.date_of_birth is not null)
         or (stg.date_of_birth is not null and tgt.date_of_birth is null)
         or stg.phone <> tgt.phone
         or (stg.phone is null and tgt.phone is not null)
         or (stg.phone is not null and tgt.phone is null)
         or stg.passport_num <> tgt.passport_num
         or (stg.passport_num is null and tgt.passport_num is not null)
         or (stg.passport_num is not null and tgt.passport_num is null)
         or stg.passport_valid_to <> tgt.passport_valid_to
         or (stg.passport_valid_to is null and tgt.passport_valid_to is not null)
         or (stg.passport_valid_to is not null and tgt.passport_valid_to is null)) as tmp
where dndx_dwh_dim_clients.client_id = tmp.client_id;

-- 6. Удаление в приемнике удаленных в источнике записей (формат SCD1).
delete
from dndx_dwh_dim_clients
where client_id in (select tgt.client_id
                    from dndx_dwh_dim_clients as tgt
                             left join dndx_dwh_dim_clients_stg_del as stg
                                       on tgt.client_id = stg.client_id
                    where stg.client_id is null);

drop table dndx_dwh_dim_clients_stg_del;
