select ad_date, campaign_id,
sum(spend) as "cost total", sum(impressions) as "nr. de impresii",
sum(clicks) as "nr. de click-uri", sum(value) as "valoarea totală a conversiei", -- ex. 1
sum(spend)/sum(clicks) as "CPC",
sum(spend)/sum(impressions) *1000 as "CPM",
sum(clicks)::numeric /sum(impressions) as "CTR",
(sum(value)::numeric - sum(spend))/sum(spend) as "ROMI" -- ex. 2
from facebook_ads_basic_daily
where clicks >0
group by ad_date, campaign_id;