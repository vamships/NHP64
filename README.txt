# ******************************************************************************
# Author      : Srivamshi Pittala (srivamshi.pittala.gr@dartmouth.edu)
# Advisor     : Prof. Chris Bailey-Kellogg (cbk@cs.dartmouth.edu) & Prof. Margaret E. Ackerman
# Project     : NHP 64
# Description : Help file for running the scripts to analyze luminex and functional measurements
#				associated with the Pentavalent HIV vaccine trial NHP64
# Cite        : https://doi.org/10.1038/ncomms15711
# ******************************************************************************

# Copyright (C) <2018>  <Srivamshi Pittala>

#     This program is free software: you can redistribute it and/or modify
#     it under the terms of the GNU General Public License as published by
#     the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.

#     This program is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU General Public License for more details.

#     You should have received a copy of the GNU General Public License
#     along with this program.  If not, see <https://www.gnu.org/licenses/>.

#***********************
Input Files (in the directory in/)
#***********************

#***********************
For survival analysis, use the following script
#***********************

#-----------------------
1. coxPredRisk.R
Takes about 5 min to complete
#-----------------------

===> This script performs the survival analysis using the functional measurements. 
		(1)	First, the features are pre-filtered using the polyserial correlation coefficient.
		(2) Then repeated cross-validation is performed on the features returned from pre-filtering. In this 	cross-validation, greedy backward elimination is used to select features for each fold using the training set. The most-frequent features appearing in the repeated cross-validation are used to build a final model, the results from which are used for the figures.
		(3) The features in the final model are used to discover other features that could be equally predictive of risk but were not considered since they are correlated with the final feature set.
		(4) Permutation tests are performed by shuffling the rows of the outcome labels, but keeping the rows of feature matrix the same. The permuted data are sent through the same pipeline as were the actual data (i.e. pre-filtering, repeated cross-validation, and final model evaluation). This is repeated multiple times, independently permuting the outcome labels every time.
		(5) Robustness is estimated by comparing the C-indices from using actual features to those of using permuted features.

#***********************
For binomial logistic classification, use the following script
#***********************

#-----------------------
1. predClassBinary_temporal.R
Takes about 5 min to complete
#-----------------------
===> This script performs binomial logistic classification to identify vaccine groups using the biophysical measurements at different timepoints
		(1) Classification is done using the lasso-regularized binomial logistic regression on the features. The best regularization parameter (lambda) is chosen to be the one with lowest classification error. This is repeated multiple times. A final model is trained and evaluated by using a fixed seed to determine folds.
		(2) Permutation tests are performed by shuffling the rows of the class labels, but keeping the rows of feature matrix the same. The permuted data are sent through the same pipeline as were the actual data. This is repeated multiple times, independently permuting the class labels every time.
		(3) Robustness is estimated by comparing the accuracies from using actual features to those of using permuted features.

#***********************
For generating the figures as in the manuscript, use the following script
#***********************

#-----------------------
1. generate_figures.R
#-----------------------
===> This script generates the figures as shown in the manuscript. Run this after after all the above scripts have finished successfully. The directory ‘results_figures_reference/’ can be used as a reference to what the final figure outputs should look like.

# ******************************************************************************

#-----------------------
System configuration 
#-----------------------
OS 	: Ubuntu 14.04.5 LTS
CPU : i7 8 cores @ 3.6 GHz
RAM : 24 GB

#-----------------------
Software and packages (version)
#-----------------------
01. R (3.4.3) and RStudio (1.0.143)
02. glmnet (2.0-13)
03. gplots (3.0.1)
04. ggplot2 (2.2.1)
05. effsize (0.7.1)
06. survival (2.41-3)
07. corrplot (0.84)
08. caret (6.0-77)	(Install with dependencies=TRUE)
09. survcomp (1.24.0)	(Installed via bioconductor)
10. polycor (0.7-9)
11. e1071(1.6-8)

#-----------------------
Functions used by the scripts (in the directory funcs/)
#-----------------------
01. convertKMtoEvents.R
02. coxSurvivalFinalModel.R
03. coxSurvivalWithBackSearch.R
04. createColumnColors.R
05. createSubjectColors.R
06. doCoxBackSearch.R
07. doFullSurvivalAnalysis.R
08. extractProbabilityFromKM.R
09. glmnetBiClass.R
10. heatmap4.R
11. plotConfusion.R
12. takeOffOneFeat.R
13. univariatePolyserialFilter.R