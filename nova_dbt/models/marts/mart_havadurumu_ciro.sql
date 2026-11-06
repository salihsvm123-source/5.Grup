select
    h.hava_durumu_ozeti,
    count(s.siparis_id) as toplam_siparis_sayisi,
    sum(s.toplam_ciro) as toplam_ciro,
    round(avg(s.toplam_ciro), 2) as ortalama_sepet_tutari
from {{ ref('perakende_satis') }} s
left join {{ ref('hava_durumu') }} h 
    on s.siparis_tarihi = h.tarih and s.sehir = h.sehir
group by h.hava_durumu_ozeti
order by toplam_ciro desc