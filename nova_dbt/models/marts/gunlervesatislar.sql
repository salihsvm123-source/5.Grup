with genisletilmis_satislar as (
    select
        s.siparis_id,
        s.siparis_tarihi,
        s.musteri_id,
        s.sehir,
        s.satis_kanali,
        s.kategori,
        s.urun_adi,
        s.miktar,
        s.toplam_ciro,
        -- Hafta sonu mu kontrolü (DuckDB fonksiyonları ile: 0 = Pazar, 6 = Cumartesi)
        case 
            when extract(dow from s.siparis_tarihi) in (0, 6) then 'Hafta Sonu'
            else 'Hafta İçi'
        end as zaman_dilimi,
        -- Türkçe gün adını da rapora ekleyelim ki görselde şık dursun
        case extract(dow from s.siparis_tarihi)
            when 0 then 'Pazar'
            when 1 then 'Pazartesi'
            when 2 then 'Salı'
            when 3 then 'Çarşamba'
            when 4 then 'Perşembe'
            when 5 then 'Cuma'
            when 6 then 'Cumartesi'
        end as gun_adi
    from {{ ref('satislar') }} s
    -- İstersen hava durumu ile de inner join yapabiliriz ama sadece satış bazlı 
    -- daha genel bir sepet analizi için temel satışlar tablosu yeterlidir.
)

select
    zaman_dilimi,
    kategori,
    count(distinct siparis_id) as toplam_siparis_sayisi,
    sum(miktar) as toplam_satilan_urun_adedi,
    sum(toplam_ciro) as toplam_ciro,
    round(avg(toplam_ciro), 2) as ortalama_sepet_tutari
from genisletilmis_satislar
group by 1, 2
order by zaman_dilimi desc, toplam_ciro desc