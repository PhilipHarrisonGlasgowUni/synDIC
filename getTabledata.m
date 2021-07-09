function getTabledata(ut,figg)

gtTabledata = get(ut,'data');

setappdata(0,'Table_data',gtTabledata)
close(figg)

end