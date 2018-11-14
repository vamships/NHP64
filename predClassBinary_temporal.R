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

dir_res = paste('results_predClassBinary_temporal/',sep="")
dir.create(dir_res)

# -------------------------------------------
# Hyper-parameters

num_tp = 6
names_tp = paste("tp_",1:num_tp,sep="")

# glmnet parameters
alphas = seq(1,1,0.1)
cvFolds = 9
repeatRun = 100
intc =TRUE
weights_bal = TRUE

# -------------------------------------------
# Data

subjects = read.csv('in/subjects.csv',header=TRUE,row.names=1)
scolors = createSubjectColors(subjects,group_colors,challenge_colors)

g1 = which(subjects[,'group']==1)
g2 = which(subjects[,'group']==2)

# Selected Luminex Feature Set
luminex_wk_1 = read.csv('in/sel_wk_1.csv',header=TRUE,row.names=1)
luminex_wk_2 = read.csv('in/sel_wk_2.csv',header=TRUE,row.names=1)
luminex_wk_3 = read.csv('in/sel_wk_3.csv',header=TRUE,row.names=1)
luminex_wk_4 = read.csv('in/sel_wk_4.csv',header=TRUE,row.names=1)
luminex_wk_5 = read.csv('in/sel_wk_5.csv',header=TRUE,row.names=1)
luminex_wk_6 = read.csv('in/sel_wk_6.csv',header=TRUE,row.names=1)

luminex_sel = vector("list",num_tp)
names(luminex_sel) = names_tp

luminex_sel[[1]] = luminex_wk_1
luminex_sel[[2]] = luminex_wk_2
luminex_sel[[3]] = luminex_wk_3
luminex_sel[[4]] = luminex_wk_4
luminex_sel[[5]] = luminex_wk_5
luminex_sel[[6]] = luminex_wk_6

# Function Feature Set
func_tp_1 = read.csv('in/func_tp_1.csv',header=T,row.names=1)
func_tp_2 = read.csv('in/func_tp_2.csv',header=T,row.names=1)
func_tp_3 = read.csv('in/func_tp_3.csv',header=T,row.names=1)
func_tp_4 = read.csv('in/func_tp_4.csv',header=T,row.names=1)
func_tp_5 = read.csv('in/func_tp_5.csv',header=T,row.names=1)
func_tp_6 = read.csv('in/func_tp_6.csv',header=T,row.names=1)

func_AD = c(1:7)

# Selected Function Feature Set
func_sel = vector("list",num_tp)
names(func_sel) = names_tp

func_sel[[1]] = func_tp_1[,func_AD]
func_sel[[2]] = func_tp_2[,func_AD]
func_sel[[3]] = func_tp_3[,func_AD]
func_sel[[4]] = func_tp_4[,func_AD]
func_sel[[5]] = func_tp_5[,func_AD]
func_sel[[6]] = func_tp_6[,func_AD]

# Combine luminex and function feature sets

feats_sel = vector("list",num_tp)
names(feats_sel) = names_tp

feats_sel[[1]] = cbind(func_sel[[1]],luminex_sel[[1]])
feats_sel[[2]] = cbind(func_sel[[2]],luminex_sel[[2]])
feats_sel[[3]] = cbind(func_sel[[3]],luminex_sel[[3]])
feats_sel[[4]] = cbind(func_sel[[4]],luminex_sel[[4]])
feats_sel[[5]] = cbind(func_sel[[5]],luminex_sel[[5]])
feats_sel[[6]] = cbind(func_sel[[6]],luminex_sel[[6]])

# -------------------------------------------
# Do classification and track across timepoints

group = as.matrix((subjects[,'group']==2)*1,ncol=1)
colnames(group) = c('group')
classes = cbind(group)

acc_tp = matrix(NA,nrow=num_tp,ncol=2)
colnames(acc_tp) = c('Actual','Permuted')
rownames(acc_tp) = c('Week 02','Week 06','Week 15','Week 23','Week 49','Week 90')

feats_used_tp = numeric(num_tp)
names(feats_used_tp) = names_tp

for(tpIdx in 3:num_tp){
  
  dir_class = paste(dir_res,"class_",names_tp[[tpIdx]],"/",sep="")
  dir.create(dir_class)
  
  cat("\n\n",rep("*",30),"\n")
  cat("Working on tp : ",names_tp[tpIdx],"\n")
  cat("Selected set has : ",ncol(feats_sel[[tpIdx]]),"features\n")
  
  feats_tp = feats_sel[[tpIdx]]
  
  feats_tp = scale(feats_tp)
  na_idx = which(is.na(feats_tp),arr.ind=TRUE)
  if(length(na_idx)!=0){
    
    feats_tp[na_idx] = 0
    
  }
  
  feats_used_tp[tpIdx] = ncol(feats_tp)
  
  label = classes
  weights = rep(1,length(label))
  weights[which(label==1)] = sum(label==0)/sum(label==1)
  
  class_model = glmnetBiClass(feats_tp,label,weights,feats_used_tp[tpIdx],intc,alphas,cvFolds,repeatRun)
  
  # -------------------------------------------
  # Visualize prediction performance
  # -------------------------------------------
  
  pdf(paste(dir_class,'best_model.pdf',sep=""))
  plot(class_model$final_fit,main=paste('alpha: ',class_model$best_alpha,'\n',sep=""))
  dev.off()
  
  # -------------
  # Plot log-odds
  # -------------
  
  pred_prob = class_model$final_fit$fit.preval[,match(class_model$final_fit$lambda.min,class_model$final_fit$lambda)]
  pred_class = (pred_prob>0.5)*1
  confMat = confusionMatrix(as.factor(pred_class),as.factor(label))
  plotConfusionBinary(confMat,label,dir_class)
  
  df = as.data.frame(cbind(label,pred_prob,subjects[,'group']))
  colnames(df) = c('label','lp','Group')
  df$label = as.factor(df$label)
  df$Group = as.factor(df$Group)
  pred_table = confMat$table
  class_tot = colSums(pred_table)
  pdf(paste(dir_class,'box_pred.pdf',sep=""))
  p = ggplot(df, aes(x=label, y=lp, color=Group)) + geom_boxplot(width=0.3,notch = F,outlier.shape = NA, na.rm=T, size=1,colour="black") + geom_point(position = position_jitter(w=0.1),size=4.5,aes(colour=Group)) + scale_x_discrete(labels=c('B/E','B/E/E/E/E')) + ylab('Probability of being B/E/E/E/E') + theme(axis.line = element_line(colour = "black",size=1), axis.title.x = element_text(size=25,colour='black'), axis.title.y = element_text(size=25,colour='black') ,axis.text.x = element_text(size=20,colour='black'), axis.text.y = element_text(size=20,colour='black'),panel.background = element_blank(), panel.grid.major.x = element_blank(), panel.grid.minor.y = element_blank(), panel.grid.major.y = element_blank(),aspect.ratio=1, legend.position='bottom') + xlab('') + scale_colour_manual(values=group_colors)
  p = p + geom_hline(yintercept=0.5,colour='black',size=1.1,linetype='dashed')
  p = p + annotate("text",x=0.64,y=0.25,size=8,label=paste("frac(",pred_table[1,1],",",class_tot[1],")",sep=""),parse=T)
  p = p + annotate("text",x=0.64,y=0.75,size=8,label=paste("frac(",pred_table[2,1],",",class_tot[1],")",sep=""),parse=T)
  p = p + annotate("text",x=2.34,y=0.75,size=8,label=paste("frac(",pred_table[2,2],",",class_tot[2],")",sep=""),parse=T)
  p = p + annotate("text",x=2.34,y=0.25,size=8,label=paste("frac(",pred_table[1,2],",",class_tot[2],")",sep=""),parse=T)
  print(p)
  dev.off()
  
  # -------------
  # Plot coefficients
  # -------------
  
  coeff_min = class_model$coeff_min
  coeff_min_idx = class_model$coeff_min_idx
  coeff_min_nz_idx = which(coeff_min!=0)
  
  pdf(paste(dir_class,'coeffs_min.pdf',sep=""))
  if(length(coeff_min_nz_idx)!=0){
    
    coeff_min = coeff_min[coeff_min_nz_idx]
    coeff_min_idx = coeff_min_idx[coeff_min_nz_idx]
    
    coeff_colors = rep(group_colors[1],length(coeff_min))
    coeff_colors[which(coeff_min>0)] = group_colors[2]
    
    par(mar=c(17,7,2,0.5))
    barplot(coeff_min,col=coeff_colors,main=c("Predictor Coefficients"),las=2,names.arg=names(coeff_min),cex.names=1.4,width=0.75,ylab='',cex.axis = 2)
    mtext(expression(paste('Coefficient',sep="")), side=2, line=4, cex=3)
    
    
    
  }else{
    
    plot(c(0,1),c(0,1),type='n',xaxt='n',yaxt='n',xlab='',ylab=''); text(0.5,0.5,'(empty model)')
    
  }
  dev.off()
  
  coeffs_sel = coeff_min_idx[c(1,length(coeff_min))]
  
  feats_top = feats_sel[[tpIdx]][,coeffs_sel]
  
  pdf(paste(dir_class,"biplot.pdf",sep=""))
  df = data.frame(cbind(feats_top,subjects[,'group']))
  colnames(df) = c('f1','f2','label')
  df$label = as.factor(df$label)
  
  p = ggplot(df,aes(x=f2,y=f1,colour=label)) + geom_point(size=4,aes(colour=label)) + theme(axis.line = element_line(colour = "black",size=1), axis.title.x = element_text(size=20,colour='black'), axis.title.y = element_text(size=20,colour='black') ,axis.text.x = element_text(size=15,colour='black'), axis.text.y = element_text(size=15,colour='black'),panel.background = element_blank(), panel.grid.major.x = element_blank(), panel.grid.minor.y = element_blank(), panel.grid.major.y = element_blank(), legend.position='none') + scale_color_manual(values=group_colors) + scale_fill_manual(values=group_colors) + xlab(colnames(feats_top)[2]) + ylab(colnames(feats_top)[1])
  print(p)
  dev.off()
  
  cat('Rept : Mean of Classification Error',class_model$repeat_mse_min,'(',class_model$repeat_mse_min_sd,')\n')
  cat('Perm : Mean of Classification Error',class_model$permut_mse_min,'(',class_model$permut_mse_min_sd,')\n')
  
  robust_test = as.data.frame(cbind(1-class_model$cv_repeat[,'min'],1-class_model$cv_permut[,'min']))
  colnames(robust_test) = c('Actual','Permuted')
  
  df_test = as.data.frame(cbind(c(rep(1,repeatRun),rep(2,repeatRun)),as.vector(as.matrix(robust_test))))
  colnames(df_test) = c('label','Acc')
  df_test$label = as.factor(df_test$label)
  
  diff_test = wilcox.test(robust_test[,1],robust_test[,2],alternative="two.sided")
  eff_test = cliff.delta(robust_test[,1],robust_test[,2])
  eff_interp = as.character(eff_test$magnitude)
  
  write.csv(df_test,file=paste(dir_class,'robust.csv',sep=""),row.names = T)
  
  pdf(paste(dir_class,'robust_test_v.pdf',sep=""))
  p = ggplot(df_test,aes(x=label,y=Acc)) + geom_violin(size=1,colour="black",aes(fill=label)) + scale_x_discrete(labels=c('Actual','Permuted')) + scale_y_continuous(limits = c(0,1), breaks=seq(0,1,0.1)) + theme(axis.line = element_line(colour = "black",size=1), axis.title.x = element_text(size=15,colour='black'), axis.title.y = element_text(size=15,colour='black') ,axis.text.x = element_text(size=20,colour='black'), axis.text.y = element_text(size=12,colour='black'),panel.background = element_blank(), panel.grid.major.x = element_blank(), panel.grid.minor.y = element_blank(), panel.grid.major.y = element_blank(), legend.position='bottom') + scale_fill_manual(values=c('darkorange3','darkslategray4')) + xlab("") + ylab('Balanced Accuracy\n')
  p = p + geom_hline(yintercept=0.5,colour='black',size=0.78,linetype='dashed',alpha=0.7)
  p = p + geom_hline(yintercept=median(robust_test$Actual,na.rm=T),colour='darkorange3',size=1.2,linetype='dashed',alpha=0.7)
  p = p + geom_hline(yintercept=median(robust_test$Permuted,na.rm=T),colour='darkslategray4',size=1.2,linetype='dashed',alpha=0.7)
  p = p + annotate("segment",x=1,xend=2,y=0.1,yend=0.1,size=2)
  p = p + annotate("text",x=1.5,y=0.05,size=6,label=paste('P : ',format(diff_test$p.value,digits=3,scientific=T)))
  p = p + annotate("text",x=1.5,y=0.15,size=6,label=paste('eff : ',format(eff_test$estimate,digits=3,scientific=T),eff_interp))
  print(p)
  dev.off()
  
  acc_tp[tpIdx,] = c(1-class_model$repeat_mse_min,1-class_model$permut_mse_min)

}

pdf(paste(dir_res,'overall.pdf',sep=""))
barplot(t(acc_tp),beside=T,col=c('darkorange3','darkslategray4'),ylab='Mean True Postive Rate',xlab='Timepoint')
abline(h=0.5,lwd=2,lty=2)
legend('topleft',legend=c('Actual','Permuted'),fill=c('darkorange3','darkslategray4'))
dev.off()

pdf(paste(dir_res,'overall_sel.pdf',sep=""))
barplot(t(acc_tp[3:num_tp,]),beside=T,col=c('darkorange3','darkslategray4'),ylab='Mean True Postive Rate',xlab='Timepoint',cex.lab=1.3,cex.axis=1.3)
abline(h=0.5,lwd=2,lty=2)
legend('topleft',legend=c('Actual','Permuted'),fill=c('darkorange3','darkslategray4'))
dev.off()

pdf(paste(dir_res,'feats_used.pdf',sep=""))
barplot(feats_used_tp,col=tp_colors,ylab='Features after filtering',xlab='Timepoint')
dev.off()