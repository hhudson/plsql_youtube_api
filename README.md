#

# PL/SQL YouTube API

This repo essentially contains some table and PL/SQL logic scripts to facilitate the routine capture of YouTube API stats (likes, views, comments) for a given YouTube playlist.

## Step 1 - get your Google Cloud Platform API Key

Per the [Google provided instructions](https://developers.google.com/youtube/v3/docs#calling-the-api):

- sign into the [Developer's Console](https://console.developers.google.com/)
- create / select a project visit the API Access Pane
- click 'Enable APIS and Services' and enable [YouTube Data API v3](https://developers.google.com/youtube/v3/docs/?apix=true)
- return to your project console and visit the 'Credentials section', where you can generate an API Key. Copy and store it's value for step 3

## Step 2 - get your YouTube Playlist ID

- The easiest way to achieve this is to visit your YouTube playlist in a browser and capture the value that follows the "list" parameter. For eg, in the following url, the Playlist ID is "PLCAYBJ7ynpQQQrdwKFBZu8Kx9VTFt-pRP":

```
https://www.youtube.com/watch?v=-JK6h9mAuQc&list=PLCAYBJ7ynpQQQrdwKFBZu8Kx9VTFt-pRP
```

## Step 3 - add your values to your code

Edit [youtube_utils.pkb](packages/youtube_utils.pkb) and define the values at the top of the script with the 2 parameters you've captured in steps 1 & 2:

```plsql
g_key           constant varchar2(63) := '[CHANGEME]';
g_playlist_id   constant varchar2(63) := '[CHANGEME]';
```

## Step 4 - install the tables and package

Run the [\_release.sql](release/_release.sql) script to install the 3 tables and 1 package into your Oracle database.

## Step 5 - run your code / test

```plsql
begin
  youtube_utils.capture_stats;
end;
```
