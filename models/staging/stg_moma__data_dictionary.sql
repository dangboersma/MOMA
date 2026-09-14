with source as (

    select *
    from read_csv_auto('data/raw/MoMA_data_dictionary.csv', header = true, sample_size = -1)

),

renamed as (

    select
        try_cast("Table" as varchar) as source_table,
        try_cast("Field" as varchar) as source_field,
        try_cast("Description" as varchar) as field_description
    from source

),

cleaned as (

    select
        nullif(trim(source_table), '') as source_table,
        nullif(trim(source_field), '') as source_field,
        nullif(trim(field_description), '') as field_description
    from renamed
    where source_table is not null
      and source_field is not null

),

deduplicated as (

    select *
    from cleaned
    qualify row_number() over (
        partition by source_table, source_field
        order by field_description
    ) = 1

),

final as (

    select
        md5(source_table || '|' || source_field) as data_dictionary_sk,
        source_table,
        source_field,
        field_description
    from deduplicated

)

select * from final
