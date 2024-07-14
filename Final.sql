with venit_lunar as (
	select
		date(date_trunc('month', payment_date)) as luna_plata,
		user_id,
		game_name,
		sum(revenue_amount_usd) as venit_total
	from project.games_payments gp
	group by luna_plata, user_id, game_name
),
prev_next_luna as (
	select
		*,
		date(luna_plata - interval '1' month) as previous_luna,
		date(luna_plata + interval '1' month) as next_calendar_month,
		lag(venit_total) over(partition by user_id order by luna_plata) as previous_paid_month_revenue,
		lag(luna_plata) over(partition by user_id order by luna_plata) as previous_paid_month,
		lead(luna_plata) over(partition by user_id order by luna_plata) as next_paid_month
	from venit_lunar
),
metrici_venit as (
	select
		luna_plata,
		user_id,
		game_name,
		venit_total,
		case 
			when previous_paid_month is null 
				then venit_total
		end as mrr_new,
		case 
			when previous_paid_month = previous_luna 
				and venit_total > previous_paid_month_revenue 
				then venit_total - previous_paid_month_revenue
		end as mrr_expansion,
		case 
			when previous_paid_month = previous_luna
			and venit_total < previous_paid_month_revenue
				then venit_total - previous_paid_month_revenue
		end as mrr_contraction,
		case 
			when next_paid_month is null 
			or next_paid_month != next_calendar_month
				then venit_total
		end as churned_venit,
		case 
			when previous_paid_month != previous_luna
				and previous_paid_month is not null
				then venit_total
		end as back_from_churn_venit,
		case 
			when next_paid_month is null 
			or next_paid_month != next_calendar_month
				then next_calendar_month
		end as churn_luna
	from prev_next_luna
)
select gpu.language,
	gpu.has_older_device_model,
	gpu.age,
	mv.*
from metrici_venit mv
left join project.games_paid_users gpu using (user_id);