{smcl}
{* documented: January 2018}{...}
{cmd:help eq5dmap}{right: ({browse "http://www.stata-journal.com/article.html?article=st0528":SJ18-2: st0528})}
{hline}

{title:Title}

{p2colset 5 16 18 2}{...}
{p2col:{cmd:eq5dmap} {hline 2}}A command for mapping EQ-5D-3L and EQ-5D-5L
{p_end}
{p2colreset}{...}


{title:Syntax}

{p 8 15 2}
{cmd:eq5dmap} {it:outputvarname} {ifin} {weight}{cmd:,} 
{opt cov:ariates(varlist)} 
{{opt items(varlist)}|{opt score(varname)}}
[{it:{help eq5dmap##eq5dmap_options:eq5dmap_options}}]{p_end}

{synoptset 28 tabbed}{...}
{marker eq5dmap_options}{...}
{synopthdr :eq5dmap_options}
{synoptline}
{p2coldent :* {opth cov:ariates(varlist)}}specify the variables used as covariates: age and gender (see below){p_end}
{p2coldent :* {opt items(varlist)}}specify the variables which contain observed values for the five EQ-5D domain items to map from; the list must contain five variables{p_end}
{p2coldent :* {opth score(varname)}}specify a variable which contains the value of the EQ-5D utility score to map from{p_end}
{synopt :{opt mo:del(modelname)}}specify the model to be used for the mapping;
default is {cmd:model(EQGcopula)}{p_end}
{synopt :{opt dire:ction(mappingdirection)}}specify the direction to be used for the mapping; default is {cmd:direction(3->5)}{p_end}
{synopt :{opt values3(3Lvaluesetname)}}specify the EQ-5D-3L value set; default is {cmd:values3(UK)} and currently the only one offered{p_end}
{synopt :{opt values5(5Lvaluesetname)}}specify the EQ-5D-5L value set; default is {cmd:values5(UK)} and currently the only one offered{p_end}
{synopt :{opt bw:idth(#)}}specify the bandwidth; default is {cmd:bwidth(0)}{p_end}
{synoptline}
{p2colreset}{...}
{p 4 6 2}
* {cmd:covariates()} is required.  Either {cmd:items()} or {cmd:score()} is
required.{p_end}
{p 4 6 2}
{cmd:aweight}s, {cmd:fweight}s, and {cmd:iweight}s are allowed; see 
{help weight}.{p_end}


{title:Description}

{pstd}
{cmd:eq5dmap} is a community-contributed command that allows outcomes measured
using the older EQ-5D-3L instrument to be converted into (expected) utility
values for the newer EQ-5D-5L and vice versa.  Mapping can be carried out from
the individual EQ-5D items or from a specified (exact or approximate) EQ-5D
score.


{title:Options}

{phang}
{opth covariates(varlist)} specifies the variables used as covariates.
Mapping is age and gender specific, so there are two covariates.  They must be
specified as a {it:varlist} with the items ordered as age in years in the
interval [16,100] and gender (coded as female = {cmd:0}, male = {cmd:1}).
{cmd:covariates()} is required.

{pstd}
If the predictor is the five-dimensional EQ-5D health description:

{phang}
{opt items(varlist)} specifies the variables that contain observed values for
the five EQ-5D domain items to map from.  They must be specified as a
{it:varlist} containing five variables ordered as mobility, self-care, usual
activities, pain or discomfort, and anxiety or depression.  For 3L -> 5L
mapping, the variables should all be coded on a scale 1, 2, 3, where {cmd:1} =
no problems, ... {cmd:3} = extreme problems; for 5L -> 3L mapping, the coding
must be {cmd:1} = no problems, ... {cmd:5} = extreme problems.  Either
{cmd:items()} or {cmd:score()} is required, but not both.

{pstd}
If the predictor is a utility score rather than the health description:

{phang}
{opth score(varname)} specifies a variable that contains the value of the
utility score.  Either {cmd:items()} or {cmd:score()} is required, but not
both.

{phang}
{opt model(modelname)} specifies the model to be used for the mapping.  The
available options for {it:modelname} are {cmd:NDBgauss}, {cmd:NDBcopula},
{cmd:EQGcopula}, or {cmd:EQGgauss}.  The default is {cmd:model(EQGcopula)}.

{phang}
{opt direction(mappingdirection)} specifies the direction of mapping:
{cmd:direction(3L->5L)} specifies mapping from EQ-5D-3L to the newer EQ-5D-5L,
while {cmd:direction(5L->3L)} specifies the reverse.  The default is
{cmd:direction(3->5)}.

{phang}
{opt values3(3Lvaluesetname)} specifies one of the alternative EQ-5D-3L value
sets offered.  Currently, the only one offered is {cmd:UK}, which specifies
the UK value set described by Dolan (1997).  The default is {cmd:values3(UK)}.
This option is used only when EQ-5D-3L is the target outcome or when mapping
from an EQ-5D-3L utility score.

{phang}
{opt values5(5Lvaluesetname)} specifies one of the alternative EQ-5D-5L value
sets offered.  Currently, the only one offered is {cmd:UK}, which specifies
the UK value set described by Devlin et al. (Forthcoming).  The default is
{cmd:values5(UK)}.  This option is used only when EQ-5D-5L is the target
outcome or when mapping from an EQ-5D-5L utility score.

{phang}
{opt bwidth(#)} is the bandwidth that controls the matching of the specified
utility score to neighboring values.  The default is {cmd:bwidth(0)}, which
enforces exact matching to a point on the chosen value set; if there is a
multiplicity of points that match exactly, then their average is returned as
the value for {it:outputvarname}.  If there is no exact match within the
neighborhood defined by the bandwidth, then {it:outputvarname} is returned
with a missing value, and a warning is written to the log file.


{title:Examples}

{pstd}
Predicting EQ-5D-5L (Devlin et al. [Forthcoming] UK value set) using the
EQG-based copula mapping model, the EQ-5D-3L item variables {cmd:mob3L},
{cmd:sel3L}, {cmd:act3L}, {cmd:pai3L}, and {cmd:anx3L} and {cmd:age} and
{cmd:male} as covariates{p_end}
{phang2}{cmd:. eq5dmap exp_ut, covariates(age male) model(EQGcopula) items(mob3L sel3L act3L pai3L anx3L)}{p_end}

{pstd}
Predicting EQ-5D-5L (Devlin et al. [Forthcoming] UK value set) using the
NDB-based copula mapping model, the EQ-5D-3L utility score variable {cmd:sc3},
{cmd:age} and {cmd:male} as covariates, and a bandwidth of {cmd:0.001}{p_end}
{phang2}{cmd:. eq5dmap exp_ut, covariates(age male) model(NDBcopula) score(sc3) bw(0.001)}{p_end}

{pstd}
Predicting EQ-5D-3L (Dolan [1997] UK value set) using the EQG-based copula
mapping model, the EQ-5D-5L item variables {cmd:mob5L}, {cmd:sel5L},
{cmd:act5L}, {cmd:pai5L}, and {cmd:anx5L} and {cmd:age} and {cmd:male} as
covariates{p_end}
{phang2}{cmd:. eq5dmap exp_ut, covariates(age male) model(EQGcopula) items(mob5L sel5L act5L pai5L anx5L) direction(5->3)} {p_end}


{title:Stored results}

{pstd}
In addition to standard results stored by {cmd:summarize} in {opt r()},
{cmd:EQ5Dmap} stores the following in {cmd:e()}:

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Scalars}{p_end}
{synopt:{cmd:e(bwidth)}}bandwidth{p_end}

{synoptset 20 tabbed}{...}
{p2col 5 20 24 2: Macros}{p_end}
{synopt:{cmd:e(cmd)}}{cmd:eq5dmap}{p_end}
{synopt:{cmd:e(cmdline)}}command as typed{p_end}
{synopt:{cmd:e(model)}}name of model used for mapping{p_end}
{synopt:{cmd:e(covariates)}}variables used as covariates{p_end}
{synopt:{cmd:e(direction)}}direction of the mapping{p_end}
{synopt:{cmd:e(values5)}}EQ-5D-5L value set{p_end}
{synopt:{cmd:e(values3)}}EQ-5D-3L value set {p_end}
{synopt:{cmd:e(items)}}variables for the five EQ-5D domain items{p_end}
{synopt:{cmd:e(score)}}variable containing the EQ-5D utility score{p_end}


{title:References}

{phang}
Devlin, N. J., K. K. Shah, Y. Feng, B. Mulhern, and B. van Hout. Forthcoming.
Valuing health-related quality of life: An EQ-5D-5L value set for England. 
{it:Health Economics}.

{phang}
Dolan, P. 1997. Modeling valuations for EuroQol health states. 
{it:Medical Care} 35: 1095-1108.
 

{title:Authors}

{pstd}
M{c o'}nica Hern{c a'}ndez-Alava{break}
School of Health and Related Research{break}
Health Economics and Decision Science{break}
University of Sheffield{break}
Sheffield, UK{break}
monica.hernandez@sheffield.ac.uk{break}
{browse "http://www.sheffield.ac.uk/scharr/sections/heds/staff/hernandez_m"}

{pstd}
Steve Pudney{break}
School of Health and Related Research{break}
Health Economics and Decision Science{break}
University of Sheffield{break}
Sheffield, UK{break}
steve.pudney@sheffield.ac.uk{break}
{browse "http://www.sheffield.ac.uk/scharr/sections/heds/staff/pudney_s"}


{title:Also see}

{p 4 14 2}
Article:  {it:Stata Journal}, volume 18, number 2: {browse "http://www.stata-journal.com/article.html?article=st0528":st0528}{p_end}
