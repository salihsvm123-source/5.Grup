select
    case 
        when extract(month from siparis_tarihi) in (12, 1, 2) then 'Kış'
        when extract(month from siparis_tarihi) in (3, 4, 5) then 'İlkbahar'
        when extract(month from siparis_tarihi) in (6, 7, 8) then 'Yaz'
        else 'Sonbahar'
    end as mevsim,
    kategori,
    sum(miktar) as toplam_satilan_adet,
    sum(toplam_ciro) as toplam_ciro
from {{ ref('satislar') }}
group by 1, kategori
order by mevsim, toplam_ciro desc