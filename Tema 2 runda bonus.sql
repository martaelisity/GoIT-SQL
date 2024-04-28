select campaign_id, 
(sum(value)::numeric - sum(spend))/sum(spend) as "ROMI"
from facebook_ads_basic_daily
group by campaign_id 
having sum(spend)> 500000
order by "ROMI" desc limit 1;