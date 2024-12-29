INSERT INTO dndx_dwh_fact_transactions
SELECT trans_id
     , trans_date
     , card_num
     , oper_type
     , amt
     , oper_result
     , terminal
FROM dndx_stg_transactions;

INSERT INTO dndx_dwh_fact_passport_blacklist
SELECT passport, entry_dt
FROM dndx_stg_blacklist;
