drop table redu_stat;
create table redu_stat(view_name varchar2(30), rowcount number, beg_date date, end_date date);
create unique index pk_redu_stat on redu_stat(view_name);
commit;
exit	

