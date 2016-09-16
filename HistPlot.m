function HistPlot(data)
   bar(data); 
   XTickLabel = [0:1024:32768];
   XTick = [0:32:1024];
   set(gca,'XTick', XTick);
   set(gca,'XTickLabel', XTickLabel);
end