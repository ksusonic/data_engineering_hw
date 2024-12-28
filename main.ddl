--
create table dndx_stg_clients (
    client_id varchar primary key,
    last_name varchar,
    first_name varchar,
    patrinymic varchar,
    date_of_birth date,
    passport_num varchar,
    passport_valid_to date,
    phone varchar
);

create table dndx_dwh_dim_clients (
    client_id varchar primary key,
    last_name varchar,
    first_name varchar,
    patrinymic varchar,
    date_of_birth date,
    passport_num varchar,
    passport_valid_to date,
    phone varchar,
    create_dt date,
    update_dt date
);

create table dndx_dwh_dim_clients_hist (
    client_id varchar primary key,
    last_name varchar,
    first_name varchar,
    patrinymic varchar,
    date_of_birth date,
    passport_num varchar,
    passport_valid_to date,
    phone varchar,
    effective_from date,
    effective_to date,
    deleted_flg boolean
);

--
create table dndx_stg_accounts (
    account_num varchar primary key,
    valid_to date,
    client varchar references dndx_stg_clients (client_id)
);

create table dndx_dwh_dim_accounts (
    account_num varchar primary key,
    valid_to date,
    client varchar references dndx_dwh_dim_clients (client_id),
    create_dt date,
    update_dt date
);

create table dndx_dwh_dim_accounts_hist (
    account_num varchar primary key,
    valid_to date,
    client varchar references dndx_dwh_dim_clients (client_id),
    effective_from date,
    effective_to date,
    deleted_flg boolean
);

create table dndx_stg_cards (
    card_num varchar primary key,
    account_num varchar references dndx_stg_accounts (account_num),
    deleted_flg boolean
);

create table dndx_dwh_dim_cards_hist (
    card_num varchar primary key,
    account_num varchar references dndx_dwh_dim_accounts (account_num),
    effective_from date,
    effective_to date,
    deleted_flg boolean
);

create table dndx_dwh_dim_cards (
    card_num varchar primary key,
    account_num varchar references dndx_dwh_dim_accounts (account_num),
    create_dt date,
    update_dt date
);

--
create table dndx_stg_terminals (
    terminal_id varchar primary key,
    terminal_type varchar,
    terminal_city varchar,
    terminal_address varchar
);

create table dndx_dwh_fact_terminals (like dndx_stg_terminals including all);

--
create table dndx_stg_transactions (
    trans_id varchar primary key,
    trans_date date,
    card_num varchar references dndx_stg_cards (card_num),
    oper_type varchar,
    amt decimal,
    oper_result varchar,
    terminal varchar references dndx_stg_terminals (terminal_id)
);

create table dndx_dwh_fact_transactions (like dndx_stg_transactions including all);

--
create table dndx_stg_blacklist (passport_num varchar primary key, entry_dt date);

create table dndx_dwh_fact_blacklist (like dndx_stg_blacklist including all);

--
create table dndx_dwh_dim_terminals (
    terminal_id varchar primary key,
    terminal_type varchar,
    terminal_city varchar,
    terminal_address varchar,
    create_dt date,
    update_dt date
);

create table dndx_dwh_dim_terminals_hist (
    terminal_id varchar primary key,
    terminal_type varchar,
    terminal_city varchar,
    terminal_address varchar,
    effective_from date,
    effective_to date,
    deleted_flg boolean
);
