# ******************************************************************************
# Author      : Srivamshi Pittala
# Advisor     : Prof. Chris Bailey-Kellogg
# Project     : NHP 64
# Description : Performs survival analysis using the biophysical measurements
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

rm(list = ls())

source('funcsToImport.R')

dir_class_temporal = 'results_predClassBinary_temporal/'
dir_cph = 'results_coxPred/'

dir_res = paste('results_figures/',sep="")
dir.create(dir_res)

# -------------------------------------------
# Figure 4
# -------------------------------------------

dir_fig_4 = paste(dir_res,'fig_4/',sep="")
dir.create(dir_fig_4)

file.copy(paste(dir_class_temporal,'class_tp_4/box_pred.pdf',sep=""),paste(dir_fig_4,'fig_f4a.pdf',sep=""))
file.copy(paste(dir_class_temporal,'class_tp_4/coeffs_min.pdf',sep=""),paste(dir_fig_4,'fig_f4b.pdf',sep=""))
file.copy(paste(dir_class_temporal,'class_tp_4/biplot.pdf',sep=""),paste(dir_fig_4,'fig_f4c.pdf',sep=""))
file.copy(paste(dir_class_temporal,'overall_sel.pdf',sep=""),paste(dir_fig_4,'fig_s5d.pdf',sep=""))
file.copy(paste(dir_class_temporal,'class_tp_4/robust_test_v.pdf',sep=""),paste(dir_fig_4,'fig_s5e.pdf',sep=""))

# -------------------------------------------
# Figure 5
# -------------------------------------------

dir_fig_5 = paste(dir_res,'fig_5/',sep="")
dir.create(dir_fig_5)

file.copy(paste(dir_cph,'surv/final/km_compare.pdf',sep=""),paste(dir_fig_5,'fig_f5a.pdf',sep=""))
file.copy(paste(dir_cph,'surv/final/CvR_test.pdf',sep=""),paste(dir_fig_5,'fig_f5b.pdf',sep=""))
file.copy(paste(dir_cph,'surv/final/final_feat_selection_sorted.pdf',sep=""),paste(dir_fig_5,'fig_f5e.pdf',sep=""))
file.copy(paste(dir_cph,'surv/final/CvR_compare_test_2.pdf',sep=""),paste(dir_fig_5,'fig_f5c.pdf',sep=""))
file.copy(paste(dir_cph,'perm/robust_test.pdf',sep=""),paste(dir_fig_5,'fig_f5d.pdf',sep=""))
