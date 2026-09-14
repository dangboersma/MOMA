with source as (

    select *
    from read_csv_auto('data/raw/Artists.csv', header = true, sample_size = -1)

),

renamed as (

    select
        try_cast("ConstituentID" as integer) as constituent_id,
        try_cast("DisplayName" as varchar) as display_name,
        try_cast("ArtistBio" as varchar) as artist_bio,
        try_cast("Nationality" as varchar) as nationality,
        try_cast("Gender" as varchar) as gender,
        try_cast("BeginDate" as integer) as begin_date,
        try_cast("EndDate" as integer) as end_date,
        try_cast("Wiki QID" as varchar) as wiki_qid,
        try_cast("ULAN" as bigint) as ulan_id
    from source

),

cleaned as (

    select
        constituent_id,
        nullif(trim(display_name), '') as display_name,
        nullif(trim(artist_bio), '') as artist_bio,
        nullif(trim(nationality), '') as nationality,
        nullif(lower(trim(gender)), '') as gender,
        nullif(begin_date, 0) as begin_date,
        nullif(end_date, 0) as end_date,
        nullif(trim(wiki_qid), '') as wiki_qid,
        ulan_id
    from renamed
    where constituent_id is not null

),

deduplicated as (

    select *
    from cleaned
    qualify row_number() over (
        partition by constituent_id
        order by display_name
    ) = 1

),

final as (

    select
        md5(cast(constituent_id as varchar)) as artist_sk,
        constituent_id,
        display_name,
        artist_bio,
        nationality,
        gender,
        begin_date,
        end_date,
        wiki_qid,
        ulan_id
    from deduplicated

)

select * from final
