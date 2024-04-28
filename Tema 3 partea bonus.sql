with marketing as (
select fabd.ad_date, fc.campaign_name, fa.adset_name, fabd.spend, fabd.impressions, fabd.reach, fabd.clicks, 
fabd.leads, fabd.value
from facebook_ads_basic_daily fabd 
left join facebook_adset fa on fa.adset_id = fabd.adset_id
left join facebook_campaign fc on fc.campaign_id = fabd.campaign_id 
union 
select ad_date, campaign_name,adset_name, spend, impressions, reach, clicks, leads, value
from google_ads_basic_daily gabd 
)
select campaign_name, adset_name,
(sum(value):: numeric - sum(spend))/sum(spend) as "ROMI"
from marketing
group by campaign_name, adset_name
having sum(spend)> 500000
order by "ROMI" desc limit 1;