* Important papers and packages:
* did_imputation: Event studies: robust and efficient estimation, testing, and plotting
* This is a Stata package for Borusyak, Jaravel, and Spiess (2024) REStud, "Revisiting Event Study Designs: Robust and Efficient Estimation" and (Borusyak et al. 2021)
*
* did_multiplegt_dyn: Estimation of event-study Difference-in-Difference (DID) estimators in designs with multiple groups and periods and with a potentially non-binary treatment that may increase or decrease multiple times, based on Difference-in-Differences Estimators of Intertemporal Treatment Effects (2024) Review of Economics and Statistics, Clément de Chaisemartin,  Xavier D'Haultfœuille
*
* did_multiplegt_stat In stat mode, the command computes heterogeneity-robust DID estimators introduced in de Chaisemartin and D'Haultfoeuille (2020) and de Chaisemartin et al. (2022). These estimators can be used with a non-binary (discrete or continuous) and non-absorbing treatment. However, they assume that past treatments do not affect the current outcome. Finally, these estimators can be used to compute IV-DID estimators, relying on a parallel-trends assumption with respect to an instrumental variable rather than the treatment. de Chaisemartin, C and D'Haultfoeuille, X (2020). American Economic Review, vol. 110, no. 9. Two-Way Fixed Effects Estimators with Heterogeneous Treatment Effects
* de Chaisemartin, C, D'Haultfoeuille, X, Pasquier, F, Vazquez‐Bare, G (2022). Difference-in-Differences for Continuous Treatments and Instruments with Stayers.

* csdid (Difference-in-Differences with multiple time periods, Callaway and Sant'Anna (2021)) and drdid ( Sant'Anna and Zhao (2020)

* eventstudyinteract (Estimating Dynamic Treatment Effects in Event Studies with Heterogeneous Treatment Effects (2020)). eventstudyinteract is a Stata package that implements the interaction weighted estimator for an event study. Sun and Abraham (2021) proposes this estimator as an alternative to the canonical two-way fixed effects regressions with relative time indicators. Sun and Abraham (2020) proves that this estimator is consistent for the average dynamic effect at a given relative time even under heterogeneous treatment effects. As outlined in the paper, eventstudyinteract uses either never-treated units or last-treated units as the comparison group. A similar estimator is Callaway and Sant'Anna (2020), which uses all not-yet-treated units for comparison. eventstudyinteract also constructs pointwise confidence intervals valid for the effect at a given relative time. The bootstrap-based inference by Callaway and Sant'Anna (2020) constructs simultaneous confidence intervals that are valid for the entire path of dynamic effects, i.e., effects across multiple relative times.

* sdid: This Stata package implements the synthetic difference-in-differences estimation procedure, along with a range of inference and graphing procedures, following Arkhangelsky et al., (2021). Arkhangelsky et al. provide a code implementation in R, with accompanying materials here: synthdid. Here we provide a native Stata implementation, principally written in Mata. This package extends the funcionality of the original R package, allowing very simply for estimation in contexts with staggered adoption over multiple treatment periods (as well as in a single adoption period as in the original code). We can also estimate SC and DID

* sdid_event: If you wish to implement Event Study analysis with SDiD, please check out

* twowayfeweights

* staggered: The staggered package computes the efficient estimator for settings with randomized treatment timing, based on the theoretical results in Roth and Sant'Anna (2023). If units are randomly (or quasi-randomly) assigned to begin treatment at different dates, the efficient estimator can potentially offer substantial gains over methods that only impose parallel trends.


