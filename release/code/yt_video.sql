-- drop objects

PRO ..  yt_video
alter session set current_schema = ILA;
/

begin
    execute immediate 'drop table yt_video cascade constraints purge';
exception
    when others then
        null;
end;
/

-- create tables
create table yt_video (
    video_id                       varchar2(31 char)
                                   constraint yt_video_pk primary key,
    title                          varchar2(255 char)
                                   constraint yt_video_title_unq unique,
    video_published_at             timestamp with local time zone,
    created                        timestamp with local time zone not null,
    created_by                     varchar2(255 char) not null,
    updated                        timestamp with local time zone not null,
    updated_by                     varchar2(255 char) not null
)
;