with source as (

    select *
    from read_csv_auto('data/raw/Artworks.csv', header = true, sample_size = -1)

),

renamed as (

    select
        try_cast("ObjectID" as integer) as object_id,
        try_cast("Title" as varchar) as title,
        try_cast("Artist" as varchar) as artist_name,
        try_cast("ConstituentID" as varchar) as constituent_ids,
        try_cast("ArtistBio" as varchar) as artist_bio,
        try_cast("Nationality" as varchar) as nationality,
        try_cast("BeginDate" as varchar) as artist_begin_date,
        try_cast("EndDate" as varchar) as artist_end_date,
        try_cast("Gender" as varchar) as gender,
        try_cast("Date" as varchar) as artwork_date,
        try_cast("Medium" as varchar) as medium,
        try_cast("Dimensions" as varchar) as dimensions,
        try_cast("CreditLine" as varchar) as credit_line,
        try_cast("AccessionNumber" as varchar) as accession_number,
        try_cast("Classification" as varchar) as classification,
        try_cast("Department" as varchar) as department,
        try_cast("DateAcquired" as date) as date_acquired,
        try_cast("Cataloged" as varchar) as cataloged,
        try_cast("URL" as varchar) as url,
        try_cast("ImageURL" as varchar) as image_url,
        try_cast("OnView" as varchar) as on_view,
        try_cast("Circumference (cm)" as double) as circumference_cm,
        try_cast("Depth (cm)" as double) as depth_cm,
        try_cast("Diameter (cm)" as double) as diameter_cm,
        try_cast("Height (cm)" as double) as height_cm,
        try_cast("Length (cm)" as double) as length_cm,
        try_cast("Weight (kg)" as double) as weight_kg,
        try_cast("Width (cm)" as double) as width_cm,
        try_cast("Seat Height (cm)" as double) as seat_height_cm,
        try_cast("Duration (sec.)" as double) as duration_sec
    from source

),

cleaned as (

    select
        object_id,
        nullif(trim(title), '') as title,
        nullif(trim(artist_name), '') as artist_name,
        nullif(trim(constituent_ids), '') as constituent_ids,
        nullif(trim(replace(replace(artist_bio, '(', ''), ')', '')), '') as artist_bio,
        nullif(trim(replace(replace(nationality, '(', ''), ')', '')), '') as nationality,
        nullif(trim(replace(replace(artist_begin_date, '(', ''), ')', '')), '') as artist_begin_date,
        nullif(trim(replace(replace(artist_end_date, '(', ''), ')', '')), '') as artist_end_date,
        nullif(lower(trim(replace(replace(gender, '(', ''), ')', ''))), '') as gender,
        nullif(trim(artwork_date), '') as artwork_date,
        nullif(trim(medium), '') as medium,
        nullif(trim(dimensions), '') as dimensions,
        nullif(trim(credit_line), '') as credit_line,
        nullif(trim(accession_number), '') as accession_number,
        nullif(trim(classification), '') as classification,
        nullif(trim(department), '') as department,
        date_acquired,
        try_cast(
            case
                when upper(trim(cataloged)) = 'Y' then 'true'
                when upper(trim(cataloged)) = 'N' then 'false'
            end as boolean
        ) as is_cataloged,
        nullif(trim(url), '') as url,
        nullif(trim(image_url), '') as image_url,
        nullif(trim(on_view), '') as on_view,
        circumference_cm,
        depth_cm,
        diameter_cm,
        height_cm,
        length_cm,
        weight_kg,
        width_cm,
        seat_height_cm,
        duration_sec
    from renamed
    where object_id is not null

),

deduplicated as (

    select *
    from cleaned
    qualify row_number() over (
        partition by object_id
        order by accession_number
    ) = 1

),

final as (

    select
        md5(cast(object_id as varchar)) as artwork_sk,
        object_id,
        title,
        artist_name,
        constituent_ids,
        artist_bio,
        nationality,
        artist_begin_date,
        artist_end_date,
        gender,
        artwork_date,
        medium,
        dimensions,
        credit_line,
        accession_number,
        classification,
        department,
        date_acquired,
        is_cataloged,
        url,
        image_url,
        on_view,
        circumference_cm,
        depth_cm,
        diameter_cm,
        height_cm,
        length_cm,
        weight_kg,
        width_cm,
        seat_height_cm,
        duration_sec
    from deduplicated

)

select * from final
