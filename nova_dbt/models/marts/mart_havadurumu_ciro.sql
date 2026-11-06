select
    h.hava_durumu_ozeti,
    count(s.siparis_id) as toplam_siparis_sayisi,
    sum(s.toplam_ciro) as toplam_ciro,
    round(avg(s.toplam_ciro), 2) as ortalama_sepet_tutari
from {{ ref('satislar') }} s
inner join {{ ref('stg_hava_durumu') }} h 
    on s.siparis_tarihi = h.tarih 
   and upper(trim(s.sehir)) = h.sehir
group by h.hava_durumu_ozeti
order by toplam_ciro desc