# gcalcli ruby wrapper
uses `gcalcli` w/ ruby  

author: Antonio Molinari  
https://github.com/magnum   
antoniomolinari@me.com  

## installation
```
  brew install galcli
  bundle i
```
optional, create a symlink in your `/usr/local/bin/` path
``` 
  FILENAME=gcalcli.rb; ln -s $(pwd)/$FILENAME /usr/local/bin/$FILENAME ; chmod +x /usr/local/bin/$FILENAME
```

## usage:

list calendars  
```
gcalcli.rb list
```

search `string` in events 
```
gcalcli.rb search string
```

search `string` in events from 2024-01-01 to 2024-03-16
```
gcalcli.rb search string from=2024-01-01 to=2020-03-16
```
