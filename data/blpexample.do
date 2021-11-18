
use "exampleforBLP.dta"

gen Mt=320000
gen sjt=qjt/Mt
egen s0=sum(sjt) , by(year)
replace s0=1-s0
gen lnsjts0=ln(sjt/s0)

xi:reg lnsjts0 i.molecule price

xi:ivreg lnsjts0  i.molecule (price= iv1 iv2 )
 
sort year
xi: blp sjt i.molecule, stochastic(price)  endog(price  = iv1 iv2) markets(year)  


