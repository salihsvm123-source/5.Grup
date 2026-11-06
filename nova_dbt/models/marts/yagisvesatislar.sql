with genisletilmis_satis_hava as (
    select
        s.siparis_id,
        s.siparis_tarihi,
        s.sehir,
        s.urun_adi,
        s.miktar,
        s.toplam_ciro,
        h.ortalama_sicaklik,
        coalesce(h.hava_durumu_ozeti, 'Bilinmiyor') as hava_durumu_ozeti,
        case 
            when lower(h.hava_durumu_ozeti) like '%rain%' 
              or lower(h.hava_durumu_ozeti) like '%drizzle%' 
              or lower(h.hava_durumu_ozeti) like '%snow%' then 'Yağışlı'
            else 'Yağışsız'
        end as yagis_durumu
    from {{ ref('satislar') }} s
    inner join {{ ref('stg_hava_durumu') }} h
        on s.siparis_tarihi = h.tarih
        and upper(trim(s.sehir)) = upper(trim(h.sehir))
),

genel as (
    select
        sum(case when yagis_durumu = 'Yağışlı' then miktar else 0 end) * 1.0
        / nullif(sum(miktar), 0) as beklenen
    from genisletilmis_satis_hava
)

select
    m.urun_adi as urun,
    sum(case when m.yagis_durumu = 'Yağışlı' then m.miktar else 0 end) as yagisli_adet,
    sum(m.miktar) as toplam_adet,
    round(
        sum(case when m.yagis_durumu = 'Yağışlı' then m.miktar else 0 end) * 1.0
        / nullif(sum(m.miktar), 0), 3
    ) as yagisli_pay,
    round(
        (sum(case when m.yagis_durumu = 'Yağışlı' then m.miktar else 0 end) * 1.0
         / nullif(sum(m.miktar), 0)) / nullif(g.beklenen, 0), 2
    ) as endeks
from genisletilmis_satis_hava m
cross join genel g
group by m.urun_adi, g.beklenen
order by endeks desc