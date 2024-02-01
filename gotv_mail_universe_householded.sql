WITH t1 as(
SELECT --dnc_2022_dem_party_support
 CASE 
WHEN clarity_2020_turnout IS NOT NULL THEN clarity_2020_turnout
WHEN vote_g_2022_ineligible = 0 THEN vote_g_2022
ELSE 0.5 END as turnout_likelihood
, * FROM `democrats.analytics_mo.person` a
LEFT JOIN `democrats.scores_mo.all_scores_2022` b ON b.person_id = a.person_id
LEFT JOIN `democrats.scores_mo.all_scores_2020` c ON c.person_id = a.person_id
LEFT JOIN `democrats.analytics_mo.person_votes` d ON d.person_id = a.person_id
WHERE reg_on_current_file = TRUE
),
t015 as(
SELECT 
--state_house_district_latest
voting_address_id
, state_senate_district_latest
, dnc_2022_dem_party_support
, turnout_likelihood
, LEAST(1, turnout_likelihood+(0.01-(turnout_likelihood*turnout_likelihood*0.01))) as turnout_with_lift
FROM t1
),
t2 as(
SELECT
turnout_with_lift
, (dnc_2022_dem_party_support-(1-dnc_2022_dem_party_support))*turnout_with_lift as turnout_vote_lift
--avg_persuasion*turnout_likelihood as net_dem_votes_persuasion
, *
FROM t015
),
t3 as(
SELECT 
--state_house_district_latest
 voting_address_id
, state_senate_district_latest
, SUM(t2.turnout_vote_lift)*0.01 as household_turnout_lift
FROM t2
GROUP BY --state_house_district_latest
 voting_address_id, state_senate_district_latest
),
t4 as(
 select approx_quantiles(t3.household_turnout_lift, 200) as percentiles
  from t3
),
t5 as(
select
  percentiles[offset(20)] as p10,
  percentiles[offset(40)] as p20,
  percentiles[offset(60)] as p30,
  percentiles[offset(80)] as p40,
  percentiles[offset(100)] as p50,
  percentiles[offset(120)] as p60,
  percentiles[offset(130)] as p65,
  percentiles[offset(140)] as p70,
  percentiles[offset(145)] as p725,
  percentiles[offset(150)] as p75,
  percentiles[offset(155)] as p775,
  percentiles[offset(160)] as p80,
  percentiles[offset(165)] as p825,
  percentiles[offset(170)] as p85,
  percentiles[offset(175)] as p875,
  percentiles[offset(180)] as p90,
  percentiles[offset(185)] as p925,
  percentiles[offset(190)] as p95,
  percentiles[offset(195)] as p975,
FROM t4
),
t7 as(
SELECT
--state_house_district_latest
 state_senate_district_latest
, COUNT(*) as total_households
, SUM(CASE WHEN t3.household_turnout_lift > 0 THEN 1 ELSE 0 END) as households_net_positive_gotv
, SUM(CASE WHEN t3.household_turnout_lift > 0 THEN t3.household_turnout_lift ELSE 0 END) as est_turnout_lift_allpositive
, SUM(CASE WHEN t3.household_turnout_lift > p975 THEN 1 ELSE 0 END) as households_975th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p975 THEN t3.household_turnout_lift ELSE 0 END) as households_975_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p95 THEN 1 ELSE 0 END) as households_95th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p95 THEN t3.household_turnout_lift ELSE 0 END) as households_95_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p925 THEN 1 ELSE 0 END) as households_925th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p925 THEN t3.household_turnout_lift ELSE 0 END) as households_925_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p90 THEN 1 ELSE 0 END) as households_90th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p90 THEN t3.household_turnout_lift ELSE 0 END) as households_90_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p875 THEN 1 ELSE 0 END) as households_875th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p875 THEN t3.household_turnout_lift ELSE 0 END) as households_875_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p85 THEN 1 ELSE 0 END) as households_85th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p85 THEN t3.household_turnout_lift ELSE 0 END) as households_85_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p825 THEN 1 ELSE 0 END) as households_825th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p825 THEN t3.household_turnout_lift ELSE 0 END) as households_825_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p80 THEN 1 ELSE 0 END) as households_80th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p80 THEN t3.household_turnout_lift ELSE 0 END) as households_80_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p775 THEN 1 ELSE 0 END) as households_775th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p775 THEN t3.household_turnout_lift ELSE 0 END) as households_775_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p75 THEN 1 ELSE 0 END) as households_75th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p75 THEN t3.household_turnout_lift ELSE 0 END) as households_75_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p725 THEN 1 ELSE 0 END) as households_725th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p725 THEN t3.household_turnout_lift ELSE 0 END) as households_725_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p70 THEN 1 ELSE 0 END) as households_70th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p70 THEN t3.household_turnout_lift ELSE 0 END) as households_70_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p65 THEN 1 ELSE 0 END) as households_65th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p65 THEN t3.household_turnout_lift ELSE 0 END) as households_65_turnoutlift
, SUM(CASE WHEN t3.household_turnout_lift > p60 THEN 1 ELSE 0 END) as households_60th_percentile_gotv
, SUM(CASE WHEN t3.household_turnout_lift > p60 THEN t3.household_turnout_lift ELSE 0 END) as households_60_turnoutlift
FROM t3 CROSS JOIN t5
GROUP BY state_senate_district_latest ORDER BY state_senate_district_latest ASC
--WHERE state_house_district_latest IN('012', '014', '016', '017', '021', '029', '030', '034', '035', '047', '056', '060', '092', '093', '094', '096', '098', '100', '101', '105', '132', '134', '135', '136'
)
--GROUP BY state_house_district_latest
--ORDER BY state_house_district_latest ASC
--)
--SELECT * FROM t5
--SELECT * FROM t6
SELECT * FROM t7