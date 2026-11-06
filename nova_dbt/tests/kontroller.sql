SELECT 
    'negatif_ciro' as hata_tipi,
    CAST(toplam_ciro AS VARCHAR) as hatali_deger
FROM {{ ref('mart_mevsimsel_urun') }}
WHERE toplam_ciro < 0

UNION ALL

SELECT 
    'hatali_indirim_orani' as hata_tipi,
    CAST(indirim_orani AS VARCHAR) as hatali_deger
FROM {{ ref('mart_indirim_kar') }}
WHERE indirim_orani < 0 OR indirim_orani > 1

UNION ALL

SELECT 
    'negatif_siparis_sayisi' as hata_tipi,
    CAST(toplam_siparis_sayisi AS VARCHAR) as hatali_deger
FROM {{ ref('mart_havadurumu_ciro') }}
WHERE toplam_siparis_sayisi < 0

UNION ALL

SELECT 
    'negatif_yagisli_adet' as hata_tipi,
    CAST(yagisli_adet AS VARCHAR) as hatali_deger
FROM {{ ref('yagisvesatislar') }}
WHERE yagisli_adet < 0