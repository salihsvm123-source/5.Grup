with source as (

    
    select * from {{ ref('perakende_satis') }}

),

renamed_and_cleaned as (

    select
        cast(SiparisID as varchar) as siparis_id,
        cast(Tarih as date) as siparis_tarihi,
        cast(Musteri_ID as varchar) as musteri_id,
        cast(Sehir as varchar) as sehir,
        cast(Bolge as varchar) as bolge,
        cast(Kanal as varchar) as satis_kanali,
        cast(Kategori as varchar) as kategori,
        cast(Urun as varchar) as urun_adi,
        cast(Miktar as integer) as miktar,
        
        
        cast(replace(cast(BirimFiyat as varchar), ',', '.') as double) as birim_fiyat,
        cast(replace(cast(Maliyet as varchar), ',', '.') as double) as maliyet,
        cast(replace(cast(IndirimOrani as varchar), ',', '.') as double) as indirim_orani,
        
        
        round(
            cast(Miktar as double) * 
            cast(replace(cast(BirimFiyat as varchar), ',', '.') as double) * 
            (1.0 - cast(replace(cast(IndirimOrani as varchar), ',', '.') as double)), 
            2
        ) as toplam_ciro,
        
        round(
            (cast(Miktar as double) * cast(replace(cast(BirimFiyat as varchar), ',', '.') as double) * (1.0 - cast(replace(cast(IndirimOrani as varchar), ',', '.') as double))) - 
            (cast(Miktar as double) * cast(replace(cast(Maliyet as varchar), ',', '.') as double)), 
            2
        ) as net_kar
    from source

)

select * from renamed_and_cleaned