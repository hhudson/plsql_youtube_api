-- If you want to add ASCII Art: https://asciiartgen.now.sh/?style=standard
-- *** DO NOT MODIFY: HEADER SECTION ***
clear screen

whenever sqlerror exit sql.sqlcode

-- define - Sets the character used to prefix substitution variables
-- Note: if you change this you need to modify every reference of it in this file and any referring files
-- set define '&'
-- verify off prevents the old/new substitution message
set verify off
-- feedback - Displays the number of records returned by a script ON=1
set feedback on
-- timing - Displays the time that commands take to complete
set timing on
-- display dbms_output messages
set serveroutput on
-- disables blank lines in code
set sqlblanklines off;


-- Log output of release
define logname = '' -- Name of the log file

set termout on
column my_logname new_val logname
select 'release_log_'||sys_context( 'userenv', 'service_name' )|| '_' || to_char(sysdate, 'YYYY-MM-DD_HH24-MI-SS')||'.log' my_logname from dual;
-- good to clear column names when done with them
column my_logname clear
set termout on
spool &logname
prompt Log File: &logname
-- *** END: HEADER SECTION ***


-- *** Release specific tasks ***

@code/yt_video.sql
@code/yt_log.sql
@code/yt_stats.sql

-- *** rerunnable scipts ***
@../triggers/yt_video_biu.sql
@../triggers/yt_log_biu.sql
@../triggers/yt_stats_biu.sql

@../packages/youtube_utils.pks
@../packages/youtube_utils.pkb

prompt Invalid objects
select object_name, object_type
from user_objects
where status != 'VALID'
order by object_name
;


-- This needs to be in place after trigger generation as some triggers follow the generated triggers above
prompt recompile invalid schema objects
begin
 dbms_utility.compile_schema(schema => user, compile_all => false);
end;
/

spool off
exit