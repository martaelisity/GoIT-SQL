with marketing as (
select fabd.ad_date, fc.campaign_name, fabd.spend, fabd.impressions, fabd.reach, fabd.clicks, fabd.leads, fabd.value
from facebook_ads_basic_daily fabd 
left join facebook_adset fa on fa.adset_id = fabd.adset_id
left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id -- informații de pe facebook, toate adunate
union 
select ad_date, campaign_name, spend, impressions, reach, clicks, leads, value
from google_ads_basic_daily gabd -- se leagă cu datele de pe Google
) 
select ad_date, campaign_name, -- coloane deja existente
sum (spend) as "Costul total", sum(impressions) as "Nr. de impresii", sum(clicks) as "Nr. de click-uri",
sum(value) as "Valoarea totală a conversiei" -- coloane cu valori agregate
from marketing
where spend >0 -- am pus această condiție ca să se elimine singurul rând de null din rezultat. merge cu orice coloană integer.
group by ad_date, campaign_name;