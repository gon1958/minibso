--
-- reduced table sizes  
--
select t.table_name
       , round(decode( t.num_rows, 0, 0, s.rowcount/t.num_rows ) * 100) exp_perc
       , round((t.avg_row_len * s.rowcount) / (1024 * 1024)) tab_size_mb
       , round((b.bytes / (1024 * 1024))) * 
              round(decode( t.num_rows, 0, 0, s.rowcount/t.num_rows ))  full_size_mb
       , trunc(sysdate - t.last_analyzed) stat_days
	   , s.rowcount
	   , trunc((s.end_date - s.beg_date) * 24 * 60) min
from redu_stat s, user_tables t, 
       (
		select sum(bytes) bytes, table_name segment_name from (
			  SELECT bytes, segment_name, segment_type, segment_name table_name, 1
				FROM user_segments s
				WHERE segment_type = 'TABLE' 
		union 
			  SELECT s.bytes, l.segment_name, 'LOB_COLUMN', l.TABLE_NAME , 2
				FROM user_lobs l, user_segments s 
				WHERE l.segment_name = s.segment_name
		union
			  SELECT s.bytes, l.index_name, l.index_type, l.TABLE_NAME , 3
				FROM user_indexes l, user_segments s 
				WHERE l.index_name = s.segment_name
		) group by table_name   
	    ) b
		  where t.table_name = substr(s.view_name, 6) and b.segment_name = t.table_name
-- and trunc((s.end_date - s.beg_date) * 24 * 60) > 0
order by round((b.bytes / (1024 * 1024))) * 
    round(decode( t.num_rows, 0, 0, s.rowcount/t.num_rows )) desc;




--
-- NOT reduced table sizes 
--
select t.table_name, tab_size_mb, trunc(bytes/(1024*1024)) full_size_mb
from user_tables t, 
      (select segment_name, sum(bytes)/(1024*1024) as tab_size_mb 
      from user_extents where segment_type = 'TABLE' group by segment_name) et, 
      (
      select sum(bytes) bytes, table_name segment_name from (
            SELECT bytes, segment_name, segment_type, segment_name table_name, 1
              FROM user_segments s
              WHERE segment_type = 'TABLE' 
      union 
            SELECT s.bytes, l.segment_name, 'LOB_COLUMN', l.TABLE_NAME , 2
              FROM user_lobs l, user_segments s 
              WHERE l.segment_name = s.segment_name
      union
            SELECT s.bytes, l.index_name, l.index_type, l.TABLE_NAME , 3
              FROM user_indexes l, user_segments s 
              WHERE l.index_name = s.segment_name
      ) group by table_name   
      ) ef
where  
not exists ( select view_name from redu_stat where view_name = 'REDU_'||t.table_name)      
and et.segment_name = t.table_name and ef.segment_name = t.table_name
order by tab_size_mb desc

