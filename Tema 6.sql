with datele_noastre as (
select fabd.ad_date, fabd.url_parameters, fabd.spend, 
fabd.impressions, fabd.reach, fabd.clicks, fabd.leads, fabd.value
from facebook_ads_basic_daily fabd 
left join facebook_adset fa on fa.adset_id = fabd.adset_id
left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id
union 
select ad_date, url_parameters,
coalesce (spend, 0), coalesce (impressions, 0),
coalesce (reach, 0), coalesce (clicks,0), coalesce (leads,0),
coalesce (value, 0)
from google_ads_basic_daily gabd
),
datele_selectate as (
select date_trunc('month', ad_date) as ad_month,
sum(spend) as suma_totala_cheltuieli, sum(impressions) as nr_afisari,
sum(clicks) as nr_clickuri, sum(value) as valoarea_totala_conversie,
case
when lower(substring(url_parameters FROM 'utm_campaign=([^&]+)')) = 'nan' then null
else decode_url (lower(substring(url_parameters FROM 'utm_campaign=([^&]+)')))
end as utm_campaign,
case 
when SUM(impressions) > 0 then (SUM(clicks)::numeric / SUM(impressions)) * 100
else null 
end as CTR,
case 
when SUM(clicks) > 0 then SUM(spend) / SUM(clicks)
else null 
end as CPC,
case 
when SUM(impressions) > 0 then (SUM(spend) / SUM(impressions)) *1000
else null 
end as CPM,
case 
when SUM(spend) > 0 then ((sum(value) - sum(spend))/sum(spend)) *100
else null 
end as ROMI
from datele_noastre
group by ad_date, url_parameters
),
datele_cu_lag AS (
select  ad_month, utm_campaign, suma_totala_cheltuieli,
nr_afisari, nr_clickuri,valoarea_totala_conversie,
CTR, CPC, CPM, ROMI,
LAG(CPM, 1) over (partition by utm_campaign order by ad_month) as prev_cpm,
LAG(CTR, 1) over (partition by utm_campaign order by ad_month) as prev_ctr,
LAG(ROMI, 1) over (partition by utm_campaign order by ad_month) as prev_romi
from datele_selectate
)
select ad_month, utm_campaign,
suma_totala_cheltuieli, nr_afisari,
nr_clickuri, valoarea_totala_conversie,
CTR, CPC, CPM, ROMI,
case 
	when prev_cpm > 0 then (CPM::numeric / prev_cpm) / prev_cpm * 100 
else null
end as cpm_diferenta_percent,
case
	when prev_ctr > 0 then (CTR::numeric / prev_ctr) / prev_ctr * 100 else null
	end as ctr_diferenta_percent,
case
	when prev_romi > 0 then (ROMI::numeric / prev_romi) / prev_romi * 100 
else null
end as romi_diferenta_percent
from datele_cu_lag;