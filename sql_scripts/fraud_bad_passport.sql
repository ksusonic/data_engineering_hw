insert into dndx_rep_fraud(event_dt, passport, fio, phone, event_type, report_dt)
select fact.trans_date                                                                      as event_dt,
       dimclients.passport_num                                                              as passport,
       dimclients.last_name || ' ' || dimclients.first_name || ' ' || dimclients.patronymic as fio,
       dimclients.phone                                                                     as phone,
       'заблокированный паспорт'                                                            as event_type,
       to_date(%s, 'YYYY-MM-DD')                                                            as report_dt
from dndx_dwh_fact_transactions fact
         left join dndx_dwh_dim_cards dimcards on trim(fact.card_num) = trim(dimcards.card_num)
         left join dndx_dwh_dim_accounts dimaccounts on dimcards.account_num = dimaccounts.account_num
         left join dndx_dwh_dim_clients dimclients on dimaccounts.client = dimclients.client_id
where (dimclients.passport_num in (select passport_num from dndx_dwh_fact_passport_blacklist)
    or dimclients.passport_valid_to is null
    or dimclients.passport_valid_to < to_date(%s, 'YYYY-MM-DD'))
  and DATE(fact.trans_date) = to_date(%s || '', 'YYYY-MM-DD')