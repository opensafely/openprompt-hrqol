*! version 1.03 29 January 2018
*! 
*! version 1.01 Mapping 3L to 5L (UK) only
*! 
*! version 1.02 Mapping two-way (UK) added
*!
*! version 1.03 EQ-5D-5L Command uses new UK (English) valuation forthcoming in Health Economics
*! 
*! Authors: Monica Hernandez and Steve Pudney

/******************************************************************************/
/*     Mapping two-way between EQ-5D-3L and EQ-5D-5L, using a                 */
/*     generalized multivariate ordinal regression model                      */
/******************************************************************************/
mata: mata clear

mata:

void expu(string scalar outvarname)
//void expu(string scalar varname, string scalar touse)

{	external real matrix lut
	real colvector _score, matmale, matage, epan, flag, outp, mattouse
	real matrix _sel, tmp //,lut
	real scalar calip, numer, denom, mon
	
	calip=strtoreal(st_local("bwidth"))	
	st_view(_score, ., st_local("score"))
	st_view(matmale, ., st_local("male"))
	st_view(matage, ., st_local("age"))
	st_view(mattouse, ., st_local("touse"))
	st_view(outp, ., outvarname)
	
	
	for (i=1; i<=rows(_score); i++) {
	
		if (mattouse[i,1]:==1) {
				
			_sel= matmale[i,1]:==lut[.,2] :& matage[i,1]:== lut[.,1]
			tmp=select(lut,_sel)
		
			epan = abs(tmp[.,3] :- _score[i,1]) :/ calip
			flag = epan :> 1	

			epan = (1 :- (epan :^ 2)) :* (1:-flag)

			numer = sum(epan :* tmp[.,4])			
			denom = sum(epan)	
			outp[i,1]=numer /denom		
		}
			
	}  //end for

}
end

program eq5dmap, eclass sortpreserve
	version 12
	tempvar id epan numer denom
	tempname u nrows
	local cmdline `"eq5dmap `0'"'
	
	syntax newvarname(generate) [if] [in] [aw fw iw pw] , COVariates(varlist)  ///
			[ MOdel(string) values5(string) ///
			  items(varlist) score(varname) values3(string) /// 
			  BWidth(real 1e-6)  DIREction(string) ] 

  
/* mark sample  */
	marksample touse, novarlist
	
	markout `touse' `covariates' 	
	
	if "`items'"!="" {
		markout `touse' `items'
	}
	if "`score'"!="" {
		markout `touse' `score'
	}
	
/*Check sample size - return error if no observations */
	qui count if `touse' 
	local N = r(N)
	if r(N) == 0 {
		error 2000
	}		
	

			  
/* deal with weights  */
if "`weight'" != "" {
		local wgt "[`weight' `exp']"
	}


/*	Check covariates   */
	if "`covariates'"=="" {
		di in red "age and gender covariates required"
		exit 301
	}
	gettoken age male : covariates
	capture assert `age'==int(`age') if `touse'
	if _rc!=0 {
		noi di in red "age not an integer variable "
		exit _rc
	}
	capture assert `age' >= 16 & `age'<=100  if `touse'
		if _rc!=0 {
		noi di in red "age outside the allowable range [16,100]. Missing values "
		noi di in red "will be generated for those observations"
		tempvar rang
		qui gen byte `rang' = 1 if `age' >= 16 & `age'<=100
		markout `touse' `rang'
		
	}

	qui summ `male' if `touse'
	//noi summ `male' if `touse'
	local a=r(min)
	local b=r(max)
	capture assert (`a'==0|`a'==1)&(`b'==0|`b'==1)&(`b'>=`a')
	if _rc!=0 {
		noi di in red "male not a binary variable "
		exit _rc
	}
	
/*	Check model option     */
	if "`model'"== "" {
		local model "EQGcopula"
	}
	if "`model'"!="NDBcopula" & "`model'"!="NDBgauss" ///
			& "`model'"!="EQGcopula" & "`model'"!="EQGgauss" {
		di in red "Invalid model choice"
		exit 301
	}
	
/* Check direction option     */ 	
	
	if "`direction'" == "" {
		di  "No direction specified: default is 3->5"
		local direction "3->5"
	}
	
	if ("`direction'" == "3->5") {
		local fromlev = 3
		local tolev = 5
	}
	
	else if ("`direction'" == "5->3") {
		local fromlev = 5
		local tolev = 3

	}
	
	else {
		di in red "Invalid choice of direction. Use 3->5 or 5->3"
		exit 301
	}
	

/*	Check "values to" option     */
	
	//allows for the use of lower case or capitals
	if "`values`tolev''"=="uk" local values`tolev' "UK"
		
	if "`values`tolev''"!="UK" & "`values`tolev''"!=""  {
		di in red "Invalid choice of `tolev'L value set"
		exit 301
	}
	if "`values`tolev''"=="" {
		di  "No `tolev'L value set specified: default is UK"
		local values`tolev'="UK"
	}



/*	Check both types of 3L input aren't requested     */
	if "`score'"!="" & "`items'"!="" {
		di in red "Cannot declare both types of input for mapping information"
		exit 301
	}

	/*	Check one type of 3L input is requested     */
	if "`score'"=="" & "`items'"=="" {
		di in red "Must declare one type of input for mapping information"
		exit 301
	}

/*	Check items, if declared, and create merge variables   */
	if "`items'"!="" {
		local k=0
		foreach v in `items' {
			local k=`k'+1
			capture assert `v'==int(`v') if `touse'
			if _rc!=0 {
				noi di in red "`v' not an integer variable "
				exit _rc
			}
			qui summ `v' if `touse'
			local a=r(min)
			local b=r(max)
			capture assert `a'>=1&`b'<=`fromlev'
			if _rc!=0 {
				noi di in red "`v' outside admissible range"
				exit _rc
			}
			qui gen byte _Y`fromlev'_`k'=`v'
		}
	}
	
/*	Check score, if relevant  */
	if "`score'"!="" {
		qui summ `score'
		if r(N)==0 {
			di in red "Utility scores all missing"
			exit 301
		}
	}
/* Check values from option */	
	if "`score'"!="" & "`values`fromlev''"=="" {
		di  "No `fromlev'L value set specified: default is UK"
		local values`fromlev' "UK"
	}
	//allows for the use of lower case and capitals
	if  "`values`fromlev''"=="uk" local values`fromlev' "UK"
	
	
	if "`score'"!="" & "`values`fromlev''"!="UK" {
		di in red "Invalid choice of `fromlev'L value set"
		exit 301
	}
	
	

	/*	Check bwidth        */
if "`score'"!="" & `bwidth'<1e-6   {
	di  "Bandwidth re-set to 1e-6"
}

di as text "Summary of inputs to eq5dmap:"
di as text "The 5-level value set is: `values5'"

gettoken agevar gendervar: covariates
di as text "The age covariate is contained in input variable: `agevar'"
di as text "The gender covariate is contained in input variable: `gendervar'"

if "`items'"!="" {
	di as text "Mapping from Y`fromlev' to v`tolev'"
	di as text "The `fromlev'-level descriptive items are contained in input variables: `items'"
}
if "`score'"!="" {
	di as text "Mapping from v`fromlev' to v`tolev'"
	di as text "The `fromlev'-level value set is: `values`fromlev''"
	di as text "The `fromlev'-level score is contained in input variable:  `score'"
	di as text "The bandwidth is: " `bwidth'
}	

*	construct merge variables   */
	qui gen _age=`age'
	qui gen _male=`male'
			
	
	
/*----------------------------------------------------------------------------*/
/*	Specification of lookup table file for both mappings:                     */
/*                                                                            */
/*  Filename:  lookup_model.dta                                               */
/*  where model is: NDBcopula or NDBgauss or EQGcopula or EQGgauss      */
/*  (representing estimates from mixed-copula or Gaussian models estimated    */
/*  from NDB or EQG data)                                                  */
/*                                                                            */
/*  Variables in file (all variable names begin with the _ character):        */
/*    (1) _Y3_1 ... _Y3_5 :  are conditioning values of the 3L descriptors    */
/*    (2) _U3 :  is the Dolan score corresponding to _Y3_1 ... _Y3_5          */
/*               (NB _U3 takes the same values across age, gender groups      */
/*                for given combination of _Y3_1 ... _Y3_5)                   */
/*    (3) _age, _male :  are the conditioning demographics                    */
/*    (4) _EUdevlin :   is the calculated expected utility using the          */
/*                      Devlin et al 5L value scale  (NB, this is constant    */
/*                      across dataset rows with the same values for          */
/*                      Y3_1 ... Y3_5, age, male)                             */
/*                                                                            */
/*  Note that the number of records in the file will be something like:       */
/*                243 x 85 x 2 = 41,320                                       */
/*  All variables should be stored in byte (_Y3_1 ... _Y3_5, _age, _male)     */
/*  or double (_U3, _EUdevlin) format                                         */
/*----------------------------------------------------------------------------*/

/*  find the ADO PLUS directory from sysdir        */
	local plusdir : sysdir PLUS
/*	Deal with the case of Y_3 -> E(u_5) mapping                         */
	

	if "`items'"!="" {
*	Merge in the lookup table for the chosen model    
		
		quietly merge m:1  _Y`fromlev'_1 _Y`fromlev'_2 _Y`fromlev'_3 ///
		    _Y`fromlev'_4 _Y`fromlev'_5 _age _male using /// 
			"`plusdir'e/eq5dmap_table`fromlev'.dta", /// 
			keep(match master)
					
			qui replace `varlist'=_EU`values`tolev''`model' if `touse'
				
		// drop all unnecessary variables from merge
		drop _merge _Y`fromlev'_1-_Y`fromlev'_5 _U`fromlev' _EU*
	}

/*	Now deal with the case of E(u_`fromlev') -> E(u_`tolev') mapping                        */

	if "`score'"!="" {
		
		preserve
		
		use "`plusdir'e/eq5dmap_table`fromlev'.dta",clear
		
	
		local colab "_age _male _U`fromlev'"
		local colab "`colab' _EU`values`tolev''`model'"
		mata:lut =st_data(.,"`colab'")
		restore
		
		//set trace on

		qui replace `varlist' = .  // not sure if we need this
		mata: expu("`varlist'")		

	} // endif
  drop _age _male
  
  qui count if `touse'
  local Nobs = r(N)
  
  if "`wgt'"=="" { 	
	di as text "Unweighted mean of predicted `tolev'L score within selected sample" 
  }
  if "`wgt'"!="" { 	
	di as text "Weighted mean of predicted `tolev'L score within selected sample" 
  }
  sum `varlist' if `touse' `wgt'
  qui local countN = r(N)
  di " "
  if `Nobs' > `countN' {
	di  "Warning: It was not possible to find a valid point using the current bandwidth."
	di  "         Missing values generated."
  }
  di " "
  //return extra results
  ereturn clear
  
  ereturn local cmd eq5dmap
  ereturn local cmdline `cmdline'
  ereturn local covariates `covariates'
  ereturn local model `model'
  ereturn local values5 `values5'
  ereturn local direction `direction'
  if "`items'"!="" {
	ereturn local items `items'
  }
  if "`score'"!="" {
	ereturn scalar bwidth = `bwidth'
	ereturn local score `score'
	ereturn local values3 `values3'
	
  }
  
  
 end
