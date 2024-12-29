--
create table if not exists dndx_stg_clients
(
    client_id         varchar primary key,
    last_name         varchar,
    first_name        varchar,
    patronymic        varchar,
    date_of_birth     date,
    passport_num      varchar,
    passport_valid_to date,
    phone             varchar,
    create_dt         date,
    update_dt         date
);

create table if not exists dndx_dwh_dim_clients
(
    client_id         varchar primary key,
    last_name         varchar,
    first_name        varchar,
    patronymic        varchar,
    date_of_birth     date,
    passport_num      varchar,
    passport_valid_to date,
    phone             varchar,
    create_dt         date,
    update_dt         date
);

--
create table if not exists dndx_stg_accounts
(
    account_num varchar primary key,
    valid_to    date,
    client      varchar,
    create_dt   date,
    update_dt   date
);

create table if not exists dndx_dwh_dim_accounts
(
    account_num varchar primary key,
    valid_to    date,
    client      varchar,
    create_dt   date,
    update_dt   date
);

create table if not exists dndx_stg_cards
(
    card_num    varchar primary key,
    account_num varchar,
    create_dt   date,
    update_dt   date
);

create table if not exists dndx_dwh_dim_cards
(
    card_num    varchar primary key,
    account_num varchar,
    create_dt   date,
    update_dt   date
);

--
create table if not exists dndx_stg_terminals
(
    terminal_id      varchar primary key,
    terminal_type    varchar,
    terminal_city    varchar,
    terminal_address varchar,
    create_dt        date,
    update_dt        date
);

create table if not exists dndx_dwh_dim_terminals
(
    like dndx_stg_terminals including all
);

--
create table if not exists dndx_stg_transactions
(
    trans_id    varchar primary key,
    trans_date  timestamp,
    card_num    varchar,
    oper_type   varchar,
    amt         decimal(18, 2),
    oper_result varchar,
    terminal    varchar,
    create_dt   date,
    update_dt   date
);

create table if not exists dndx_dwh_dim_transactions
(
    like dndx_stg_transactions including all
);

create table if not exists dndx_dwh_fact_transactions
(
    trans_id    varchar primary key,
    trans_date  timestamp,
    card_num    varchar,
    oper_type   varchar,
    amt         decimal(18, 2),
    oper_result varchar,
    terminal    varchar,
    create_dt   date,
    update_dt   date
);


--
create table if not exists dndx_stg_blacklist
(
    passport  varchar primary key,
    entry_dt  date,
    create_dt date,
    update_dt date
);

create table if not exists dndx_dwh_dim_blacklist
(
    like dndx_stg_blacklist including all
);

create table if not exists dndx_dwh_fact_passport_blacklist
(
    passport_num varchar primary key,
    entry_dt     date,
    source_dt    date
);

--
create table if not exists dndx_rep_fraud
(
    event_dt   timestamp,
    passport   varchar,
    fio        varchar,
    phone      varchar,
    event_type varchar,
    report_dt  date
);