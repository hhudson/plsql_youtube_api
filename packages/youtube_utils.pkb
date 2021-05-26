set define off;
create or replace package body youtube_utils as 

    gc_scope_prefix constant varchar2(31) := lower($$plsql_unit) || '.';
    g_key           constant varchar2(63) := apex_util.url_encode('[CHANGEME]');
    g_playlist_id   constant varchar2(63) := apex_util.url_encode('[CHANGEME]');


    procedure capture_stats
    is 
    --l_scope logger_logs.scope%type := gc_scope_prefix || 'capture_stats';
    --l_params logger.tab_param;

        procedure capture_list_of_videos
        is 
        begin

            merge into yt_video a
            using (
                    with playlist as (
                        select d0.videoid , to_date(substr(d0.videopublishedat,1,10),'yyyy-mm-dd') videopublishedat
                        from (
                        select apex_web_service.make_rest_request(
                            p_url         => 'https://www.googleapis.com/youtube/v3/playlistItems?key='||g_key||'&playlistId='||g_playlist_id||'&part=contentDetails&maxResults=50', 
                            p_http_method => 'GET' ) thejson
                            from dual
                        ) yt,
                            json_table(yt.thejson, '$'
                            columns (
                                nested path '$.items[*]'
                                columns (
                                    videoId          varchar(238) PATH '$.contentDetails.videoId',
                                    videoPublishedAt varchar(238) PATH '$.contentDetails.videoPublishedAt'
                                    ))) d0
                    )

                    select yt.videoid video_id, d2.title,  yt.videopublishedat video_published_at
                        from 
                        (select apex_web_service.make_rest_request(
                                p_url         => 'https://www.googleapis.com/youtube/v3/videos?key='||g_key||'&part=localizations&id='||apex_util.url_encode(p.videoid), 
                                p_http_method => 'GET' ) thejson,
                                p.videoid, p.videoPublishedAt
                        from playlist p
                        ) yt,
                        json_table(replace(yt.thejson,'-',''), '$'
                            columns (
                                nested path '$.items.localizations.enCA'
                                columns (
                                    title   varchar2(540) path '$.title'
                                    ))) d2
                    minus
                    select video_id, title, video_published_at
                    from yt_video
                ) b
            on (a.video_id = b.video_id)
            when matched then update set
                a.title              = b.title,
                a.video_published_at = b.video_published_at
            when not matched then
                insert (  video_id,   title,   video_published_at)
                values (b.video_id, b.title, b.video_published_at);

            --logger.log('. merged into yt_video :', l_scope, to_char(sql%rowcount));
        end capture_list_of_videos;

        procedure capture_the_stats
        is 
        l_log_id yt_log.id%type;
        begin
          insert into yt_log (name)
          values (to_char(sysdate,'YYYY-MM-DD HH24-MI-SS'))
          returning id into l_log_id;
          --logger.log('. log_id:', l_scope, to_char(l_log_id));
          
          insert into yt_stats 
                (  log_id,  video_id,  view_count,  like_count,  comment_count)
          select l_log_id, z.videoid, z.viewcount, z.likecount, z.commentcount
          from (
          with playlist as (
                select d0.videoid, to_date(substr(d0.videopublishedat,1,10),'yyyy-mm-dd') videopublishedat
                from (
                select apex_web_service.make_rest_request(
                    p_url         => 'https://www.googleapis.com/youtube/v3/playlistItems?key='||g_key||'&playlistId='||g_playlist_id||'&part=contentDetails&maxResults=50', 
                    p_http_method => 'GET' ) thejson
                    from dual
                ) yt,
                    json_table(yt.thejson, '$'
                    columns (
                        nested path '$.items[*]'
                        columns (
                            videoId          varchar(238) PATH '$.contentDetails.videoId',
                            videoPublishedAt varchar(238) PATH '$.contentDetails.videoPublishedAt'
                            ))) d0
            )

            select yt.videoid, d.viewcount, d.likecount, d.commentcount
                from (
                select apex_web_service.make_rest_request(
                        p_url         => 'https://www.googleapis.com/youtube/v3/videos?key='||g_key||'&part=statistics&id='||p.videoid, 
                        p_http_method => 'GET' ) thejson,
                        p.videoid, p.videoPublishedAt
                from playlist p
                ) yt,
                json_table(yt.thejson, '$'
                columns (
                    nested path '$.items'
                    columns (
                        viewCount    number path '$.statistics.viewCount',
                        likeCount    number path '$.statistics.likeCount',
                        commentCount number path '$.statistics.commentCount'
                        ))) d
            order by yt.videoPublishedAt
          ) z;
          --logger.log('. inserted into yt_stats :', l_scope, to_char(sql%rowcount));

        end capture_the_stats;

    begin
        --logger.log('START', l_scope, null, l_params);

        capture_list_of_videos;

        capture_the_stats;

        --logger.log('END', l_scope);
    exception when others then 
        --logger.log_error('Unhandled Exception', l_scope, null, l_params); 
        raise;  
    end capture_stats;

end youtube_utils;
/