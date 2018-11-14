plotConfusionBinary = function(conf_mat,labels,dir_class){
  
  actual = as.data.frame(table(labels))
  names(actual) = c("Reference","ReferenceFreq")
  
  df = data.frame(conf_mat$table)
  df = merge(df,actual,by=c('Reference'))
  df$Percent = df$Freq/df$ReferenceFreq
  
  pdf(paste(dir_class,'confusion.pdf',sep=''))
  p = ggplot(df,aes(x=Reference, y=Prediction,fill=Percent),color='black',size=4) + geom_tile(color="black",size=0.3) + labs(x="Reference",y="Prediction")
  p = p + geom_text(aes(x=Reference, y=Prediction, label=sprintf("%.2f", Percent)),data=df, size=10, colour="black") + scale_fill_gradient(low="white",high="#458B00",limits=c(0,1))
  print(p)
  dev.off()
  
  
}