with datele_noastre as (
select fabd.ad_date, fc.campaign_name, fabd.url_parameters, fabd.spend, 
fabd.impressions, fabd.reach, fabd.clicks, fabd.leads, fabd.value
from facebook_ads_basic_daily fabd 
left join facebook_adset fa on fa.adset_id = fabd.adset_id
left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id
union 
select ad_date, campaign_name, url_parameters,
coalesce (spend, 0), coalesce (impressions, 0),
coalesce (reach, 0), coalesce (clicks,0), coalesce (leads,0),
coalesce (value, 0)
from google_ads_basic_daily gabd
) 
select ad_date,campaign_name,
case
	when lower(substring(url_parameters,47)) = 'nan' then null
		else  decode_url (lower(substring(url_parameters FROM 'utm_campaign=([^&]+)')))
		end utm_campaign,
sum(spend) as suma_totala_cheltuieli, sum(impressions) as nr_afisari,
sum(clicks) as nr_clickuri, sum(value) as valoarea_totala_conversie,
case 
WHEN SUM(clicks) > 0 THEN SUM(clicks) / SUM(impressions)
else null 
end as CTR,
case 
WHEN SUM(clicks) > 0 THEN SUM(spend) / SUM(clicks)
else null 
end as CPC,
case 
WHEN SUM(impressions) > 0 THEN SUM(spend) / SUM(impressions) *1000
else null 
end as CPM,
case 
WHEN SUM(spend) > 0 THEN (sum(value) - sum(spend))/sum(spend)
else null 
end as ROMI
from datele_noastre
group by ad_date, campaign_name, url_parameters;