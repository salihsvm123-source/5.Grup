select
    indirim_orani,
    count(siparis_id) as siparis_adedi,
    sum(toplam_ciro) as toplam_ciro,
    sum(net_kar) as toplam_net_kar,
    round(sum(net_kar) / nullif(sum(toplam_ciro), 0) * 100, 2) as kar_marji_yuzde
from {{ ref('perakende_satis') }}
group by indirim_orani
order by indirim_orani asc