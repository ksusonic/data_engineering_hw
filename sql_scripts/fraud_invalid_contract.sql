insert into dndx_rep_fraud(event_dt, passport, fio, phone, event_type, report_dt)
select facttx.trans_date                                                                    as event_dt,
       dimclients.passport_num                                                              as passport,
       dimclients.last_name || ' ' || dimclients.first_name || ' ' || dimclients.patronymic as fio,
       dimclients.phone                                                                     as phone,
       'недействующий договор'                                                              as event_type,
       to_date(%s, 'YYYY-MM-DD')                                                            as report_dt
from dndx_dwh_fact_transactions facttx
         left join dndx_dwh_dim_cards dimcards on trim(facttx.card_num) = trim(dimcards.card_num)
         left join dndx_dwh_dim_accounts dimaccounts using (account_num)
         left join dndx_dwh_dim_clients dimclients on dimaccounts.client = dimclients.client_id
where dimaccounts.valid_to < to_date(%s, 'YYYY-MM-DD')
  and DATE(facttx.trans_date) = to_date(%s, 'YYYY-MM-DD')
