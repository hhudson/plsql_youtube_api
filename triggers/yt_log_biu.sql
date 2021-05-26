-- triggers
create or replace trigger yt_log_biu
    before insert or update 
    on yt_log
    for each row
begin
    if inserting then
        :new.created := localtimestamp;
        :new.created_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
    end if;
    :new.updated := localtimestamp;
    :new.updated_by := coalesce(sys_context('APEX$SESSION','APP_USER'),user);
end yt_log_biu;
/