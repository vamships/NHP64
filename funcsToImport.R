# ******************************************************************************
# Author      : Srivamshi Pittala
# Advisor     : Prof. Chris Bailey-Kellogg
# Project     : NHP 64
# Description : Imports the necessary packages, functions, and defines global variables
# Cite        : TBD
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

library(caret)
library(corrplot)
library(e1071)
library(effsize)
library(ggplot2)
library(glmnet)
library(gplots)
library(polycor)
library(survcomp)
library(survival)

# -----------------------------------------------------
source('funcs/convertKMtoEvents.R')
source('funcs/coxSurvivalFinalModel.R')
source('funcs/coxSurvivalWithBackSearch.R')
source('funcs/createColumnColors.R')
source('funcs/createSubjectColors.R')
source('funcs/doCoxBackSearch.R')
source('funcs/doFullSurvivalAnalysis.R')
source('funcs/extractProbabilityFromKM.R')
source('funcs/glmnetBiClass.R')
source('funcs/heatmap4.R')
source('funcs/plotConfusion.R')
source('funcs/takeOffOneFeat.R')
source('funcs/univariatePolyserialFilter.R')
# -----------------------------------------------------

group_colors = c("mediumblue","red2")
names(group_colors) = c(1,2)

group_id = c(1,2)
names(group_id) = c('BE','B4E')

challenge_colors = c('#FDD7C6','#FCC0A8','#FCA88B','#FB8E6E','#FB7656','#F75B40','#EF3E2E','#DB2823','chartreuse4')
names(challenge_colors) = c(1:9)

# the two groups of interest : IL12 and Others
km_colors = c("mediumblue","red2")
names(km_colors) = c(1,2)

# effect size
effect_colors = c('grey83','grey63','grey43','grey13')
names(effect_colors) = c('negligible','small','medium','large')

# colors based on how many challenges they survived
challenge_colors = c(colorRampPalette(c('honeydew2','grey34'))(8), 'lawngreen');
names(challenge_colors) = c(1:8, 'UI')

effect_colors = c('grey83','grey63','grey43','grey13')
names(effect_colors) = c('negligible','small','medium','large')

tp_id = 1:6
names(tp_id) = c('Post Prime 1','Post Prime 2','Post Boost 1','Post Boost 2','Post Boost 3','Post Boost 4/TOC')
names(tp_id) = c('Week-2','Week-6','Week-16','Week-23','Week-49','Week-90/TOC')
tp_colors = c('khaki','khaki4','deepskyblue','deepskyblue4','lightpink','lightpink4')
names(tp_colors) = tp_id

reagent_names = c("IgG", "FcgRIIIB NA1", "R2A-4", "C1q", "R2A-3", "R3A-1", "FcgR2B", "FcgR3AF", "FcgR2AH", "FcgR2AR", "FcgR3AV", "R3A-3", "10F12 aRhIgA")
reagent_colors = c("IgG"="steelblue3", "FcgRIIIB NA1"="lightgreen", "R2A-4"="darkolivegreen", "C1q"="orchid3", "R2A-3"="darkolivegreen1", "R3A-1"="forestgreen", "FcgR2B"="olivedrab4", "FcgR3AF"="orange2", "FcgR2AH"="darkviolet", "FcgR2AR"="deepskyblue", "FcgR3AV"="orangered3", "R3A-3"="darkslateblue", "10F12 aRhIgA"="deeppink4")

antigen_names = c("SHIV-SF162 p3 V1V2.tags", "63521 gp120 gDneg 293T monomer", "63521_171", "A244 gp120 delta11 293F monomer", "A244_171", "AA058 D11 gp120/293F", "AA07 D11 gp120/293F", "AA0858_171", "AA104 D11 gp120/239F monomer", "AA104_171", "AA107_171", "AE.A244 V1V2.tags/293F", "B.CaseA V1V2 Tags 293F-Ni", "SHIV-1157ipd3N4D11 gp120 Y173H/293F", "A1.con_env03 gp140CF_avi*", "AE01.con_env03 gp140CF_avi*", "B.con_env03 gp140 CF_avi", "C.con_env03 gp140 CF_avi*", "CON-S gp140 CFI_avi*", "ConB gp70 V1V2", "ConC gp70 V1V2", "gp120 BAL", "gp120 CM235", "gp120 Du151", "gp120 Du156.12", "gp120 JRCSF", "gp120 MN", "gp120 PVO", "gp120 TRO", "gp120 YU2", "gp120 ZM109F", "gp140 Du151", "gp41 HxBc2", "p24 HxBc2", "SF162 gp120 ", "SF162.LS gp140C.avi")

antigen_colors = c("SHIV-SF162 p3 V1V2.tags"="cyan", "63521 gp120 gDneg 293T monomer"="darkturquoise", "63521_171"="magenta", "A244 gp120 delta11 293F monomer"="maroon", "A244_171"="navy", "AA058 D11 gp120/293F"="orange4", "AA07 D11 gp120/293F"="orange", "AA0858_171"="orangered", "AA104 D11 gp120/239F monomer"="palegoldenrod", "AA104_171"="peachpuff4", "AA107_171"="peachpuff", "AE.A244 V1V2.tags/293F"="plum", "B.CaseA V1V2 Tags 293F-Ni"="purple", "SHIV-1157ipd3N4D11 gp120 Y173H/293F"="red4", "A1.con_env03 gp140CF_avi*"="red", "AE01.con_env03 gp140CF_avi*"="rosybrown4", "B.con_env03 gp140 CF_avi"="royalblue", "C.con_env03 gp140 CF_avi*"="royalblue4", "CON-S gp140 CFI_avi*"="slateblue", "ConB gp70 V1V2"="slateblue4", "ConC gp70 V1V2"="slategrey", "gp120 BAL"="springgreen", "gp120 CM235"="springgreen4", "gp120 Du151"="steelblue1", "gp120 Du156.12"="steelblue", "gp120 JRCSF"="steelblue4", "gp120 MN"="tan", "gp120 PVO"="tan4", "gp120 TRO"="thistle", "gp120 YU2"="thistle4", "gp120 ZM109F"="tomato3", "gp140 Du151"="turquoise", "gp41 HxBc2"="turquoise4", "p24 HxBc2"="wheat3", "SF162 gp120 "="yellow4", "SF162.LS gp140C.avi"="yellowgreen")