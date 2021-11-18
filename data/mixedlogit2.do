
/******************************************************************************/
/*    Estimation of mixed logit model in STATA    */
/*    on individual data                             */
/******************************************************************************/
/* Estimation of multinomial logit models with unobserved
heterogeneity using maximum simulated likelihood            */


/* Example using students evaluation */

/* One cross section 
Dataset about teachers' evaluations of pupil behavior.
  -  The variables id and scy3 identify pupils and schools.
  -  Teachers group pupils in three different quality levels (tby), our dependent variable.
  -  The data contain several additional variables explaining the quality level of the pupils, such as sex, and provide information about 1,313 pupils in 48 schools (unbalanced panel).
  -  One observation is one evaluation
variable tby "outcome variable"
variable scy3 "School id"
variable id "Pupil id"
variable sex "Sex"  (1 boy 0 girl)


*/

use "jspmix.dta", clear
distinct scy3
tab tby
list scy3 id tby sex in 1/4 ,sepby(id)

/* Simple Multinomial Logit */

mlogit tby sex, base(1) /* normalize base utility of alternative 1 */
mlogit , rrr  /* report relative-risk ratios */

constraint 1 [2=3] : sex 
constraint 2 [2=3] : _cons
mlogit tby sex, base(1) constraint(2) nocons
mlogit tby sex, base(1) constraint(1/2)
mlogit tby sex, base(1) 


/* Need a different data setup for mixed logit */
/* Need one observation per alternative, per individual */

list scy3 id tby sex in 1/4 ,sepby(id)
mlogit tby sex, base(1)
expand 3 /* model has 3 alternatives, so need to replicate data to have three observations per choice decision */
bysort id: gen alt = _n  /* generate alternative number 0 1 2 */
gen choice = (tby == alt) /* generate 0/1 dummy for chosen alternative */

list scy3 id tby sex alt choice in 1/12 ,sepby(id)
gen mid = (alt == 2)
gen low = (alt == 3)
gen sex_mid = sex*mid /* alternative dummy interacted with sex */
gen sex_low = sex*low /* alternative dummy interacted with sex */

/* replicates simple mutinomial logit  : mlogit tby sex, base(1) constraint(2) nocons  */
clogit choice sex_mid sex_low, group(id) 

/*******************************************************************/
/*   MIXED LOGIT                                                   */
/*******************************************************************/
/* Mixed logit estimation : command installed in stata running:    */
/* net install st0133_1.pkg                                        */
/* Need a different data setup for mixed logit                     */
/* Need one observation per alternative, per individual            */
/*******************************************************************/
/* Mixed logit estimation */

/* Mixed logit with normal random distribution of alternative specific mean values : mid low*/

/* An evaluation is made for each id  (pupil) */
/* We can have pupil specific random coefficient, so here for each evaluation we have a random coeff (cross section data) */

mixlogit choice sex_mid sex_low, group(id) id(id) rand(mid low) nrep(50)
/* Note that negative sd parameters are not a problem as only their square matter and represent the variance of the normally distributed coefficient */


/* We could also consider that random coefficients must be school specific  */
/* We have repeated evaluations  for several students within a school, like in panel data */
mixlogit choice  sex_mid sex_low, group(id) id(scy3) rand(mid low) nrep(50)

/*The next step is to use the coefficients from the above model as starting values for
the final model specification with correlated intercepts*/


matrix b = e(b) 
mat list b

matrix b = b[1,1..5],0,b[1,6] 
mixlogit choice sex_mid sex_low, group(id) id(scy3) rand(mid low) corr nrep(50) from(b, copy) /* corr specifies that the random coefficients are correlated.  */
mixlcov
mixlcov, sd


/* Note that negative sd parameters are not a problem 
as only their square matter and represent the variance of the normally distributed coefficient */





