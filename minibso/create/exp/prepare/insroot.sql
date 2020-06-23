SET SERVEROUTPUT ON

def truncdate='DATE ''''2020-06-05'''' '

rem Вспомогательная таблица клиентов
rem Остаются только сотрудники банка
drop table redu_client;
create table redu_client as 
	select id from z#client where id in (
		select id from (
   			select id from z#client 
			minus (
 			select id from (
        			select a1.ID from Z#CL_PRIV a1 where not exists (
          				select 1 from Z#USER b1 where b1.C_CL_PRIV_REF = a1.ID))t1 
      union all
      select id from z#client where class_id in ('CL_ORG')
      )
    ));
create index idx_redu_client on redu_client(id); 

rem INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DOCUMENT', 'c_date_exec > &truncdate AND c_date_exec < sysdate');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DOCUMENT', '1=2');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#ACCOUNT', 'c_date_close is null');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#PRODUCT', 'c_date_begin > &truncdate - 30 and state_id != ''CLOSED''');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CLIENT', 'id in (select id from redu_client)');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#u1417_reestr','c_on_date > &truncdate'); 
INSERT INTO redu_root(owner, table_name, where_clause, hidden) VALUES('IBS','z#group_link','1=2', 'Y'); 
INSERT INTO redu_root(owner, table_name, where_clause, hidden) VALUES('IBS','z#cl_operations','1=2', 'Y'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DOCUM_RC', '1=2');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CERT_RICHES','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#REPS_DATA','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#HISTORY_STATES','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#OUT_VIP_STR','1=2');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DOC_RC_AUDIT','1=2');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DOC_RC_REPL','1=2');
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#PC_RESP','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CARD_REE_HISTORY','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#BC_TUNABLE_DOCS','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#GOV_MSG','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CARD_REE_FILES','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DENY_LIST','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#REPS_PARAMS','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CL_CHECK_RESULT','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#RMSP_REGISTRY','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#SALARY_FILELINE','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#RECORDS','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#string_calc_prc','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#IP_TRAN_REE_REF','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409135_IMP','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409135#135B','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409135#135_5','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409135#135_4','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409135#135_3','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409135#135_2','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409135','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409123_IMP','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409123#123N','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409123#123D','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409123#123B','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409123','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409102#SPRAV1','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409102#SP1','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409102_IMP','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409102#_P1','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409102#_P','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409102','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101#S1','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101#NAMES','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101#N1','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101_IMP','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101#B1','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101#_S','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101#_N','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101#_B','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#F0409101','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#SUM_DOG','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#SALE_DOC','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#blob_file','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','long_data','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CLIENT_PERIOD','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CL_HIST','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#PLAN_OPER','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#ADD_BO_FOLD','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#SERVICE','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','PASSP','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','CMP3$45194','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#PARAM_FOR_PLAN','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#PL_ARC_USV','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#SUM_SYMKS','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#FACT_OPER','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','CMP3$45194','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','CMP3$1089443','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','XML_DOCUMENT','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','XML_ATTACH','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#BC_ATTACH_FILE','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#HOUSES','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','ORSA_PAR_LOB','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','ORSA_JOBS','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','ORSA_JOBS_OUT','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','ORSA_JOBS_PAR','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','ORSA_QUEUE','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','ORSA_QUEUE_OUT','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#EV_LOG','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#BC_MAP_DOC','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#JOUR_RATE_QUOTA','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#SR','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#RES_GR_RATE','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#GNI_JOUR_HISTORY','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#PATT_SIGNS','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CIT_OUT_REQUEST','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CERT_INVALID','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#EFRSB_MSG','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#BS3_DOCUM','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#BS3_CLIENT','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#BC_MAIN_DOC_SIGN','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#BC_MAIL','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CL_OPER_DOC','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CREDIT_INFO','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#PTL_HIST_REC','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CARD_REE_FIELDS','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CARD_REE_LINE','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CARD_REE_RECORDS','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#CIT_IN_REQUEST','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DOC_TAX','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DOC_CARD','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#RP_DETAIL_F250P1','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#AC_FIN#ARC','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#POST_ACTION','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#VAL_FIELD_REE','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#VZ_REQUEST','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#RP_DETAIL_F250P3','1=2'); 
INSERT INTO redu_root(owner, table_name, where_clause) VALUES('IBS','Z#DENY_FILE','1=2'); 


COMMIT;
EXIT

