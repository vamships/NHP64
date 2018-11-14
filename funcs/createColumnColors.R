createColumnColors = function(reagent_list,antigen_list,reagent_names,reagent_colors,antigen_names,antigen_colors){
    
    lcolors = matrix(NA,ncol=2,nrow=length(reagent_list))
    colnames(lcolors) = c('reagent','antigen')
    rownames(lcolors) = paste(reagent_list,antigen_list,sep='.')
    
    for(reagent in reagent_names){
      
      reagentID = grep(reagent,reagent_list)
      lcolors[reagentID,'reagent'] = reagent_colors[reagent]
      
    }
    for(antigen in antigen_names){
      
      antigenID = grep(antigen,antigen_list)
      lcolors[antigenID,'antigen'] = antigen_colors[antigen]
      
    }  
  
  return(lcolors)
  
}
