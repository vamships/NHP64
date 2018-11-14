createSubjectColors = function(subjects,group_colors,challenge_colors,interest_colors){
  
  # create row colors
  scolors = matrix(nrow=nrow(subjects), ncol=2, dimnames=list(rownames(subjects), c('group','Challenges')))
  
  for (i in 1:nrow(scolors)) {
    scolors[i,'group'] = group_colors[subjects[i,'group']]
    scolors[i,'Challenges'] = challenge_colors[subjects[i,'Challenges']]
    #if(subjects[i,'censor']==0) scolors[i,'challenges'] = 'chartreuse4'
  }
  
  return(scolors)
  
}