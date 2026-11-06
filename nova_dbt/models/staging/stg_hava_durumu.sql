with source as (

    select * from {{ ref('hava_durumu') }}

),

renamed_and_filtered as (

    select
        cast(left(cast(date as varchar), 10) as date) as tarih,
        
        upper(trim(cast(city as varchar))) as sehir,
        
        cast(plate_code as varchar) as plaka_kodu,
        cast(replace(cast(max_temp as varchar), ',', '.') as double) as max_sicaklik,
        cast(replace(cast(min_temp as varchar), ',', '.') as double) as min_sicaklik,
        round(
            (cast(replace(cast(max_temp as varchar), ',', '.') as double) + cast(replace(cast(min_temp as varchar), ',', '.') as double)) / 2.0, 
            2
        ) as ortalama_sicaklik,
        cast(replace(cast(precipitation as varchar), ',', '.') as double) as yagis_miktari,
        cast(replace(cast(wind_speed as varchar), ',', '.') as double) as ruzgar_hizi,
        cast(weather_code as varchar) as hava_kodu,
        cast(weather_desc as varchar) as hava_durumu_ozeti

    from source
    where cast(left(cast(date as varchar), 10) as date) between '2024-01-01' and '2024-12-31'

)

select * from renamed_and_filtered