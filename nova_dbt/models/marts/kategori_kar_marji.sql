{{ config(materialized='table') }}

-- Treemap: sehir filtresi + kategori kutulari + kar marji (%)
-- Grain: sehir x kategori
-- NOT: kaynak model/tablo adini kendi projene gore degistir.

with base as (

    select
        sehir,
        kategori,
        miktar,
        ciro,
        toplam_maliyet,
        kar
    from {{ ref('satislar') }}
    where sehir is not null
      and kategori is not null

),

agg as (

    select
        sehir,
        kategori,
        count(*)                as record_count,    -- kutu boyutu icin alternatif
        sum(miktar)             as toplam_miktar,   -- kutu boyutu
        sum(ciro)               as toplam_ciro,
        sum(toplam_maliyet)     as toplam_maliyet,
        sum(kar)                as toplam_kar
    from base
    group by sehir, kategori

)

select
    sehir,
    kategori,
    record_count,
    toplam_miktar,
    toplam_ciro,
    toplam_maliyet,
    toplam_kar,
    round(
        100.0 * toplam_kar / nullif(toplam_ciro, 0),
        2
    )                           as kar_marji_yuzde  -- renk / etiket (%)
from agg
