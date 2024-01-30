# gcalcli ruby wrapper
uses `gcalcli` w/ ruby  

author: Antonio Molinari  
https://github.com/magnum   
antoniomolinari@me.com  

## installation
git clone and execute
```
  brew install galcli
  bundle i
```
copy `.env.sample` to `.env` and set your default calendar
```CALENDAR_DEFAULT=you_calendar_name```

optional, create a symlink in your `/usr/local/bin/` path
``` 
  FILENAME=gcalcli.rb; ln -s $(pwd)/$FILENAME /usr/local/bin/$FILENAME ; chmod +x /usr/local/bin/$FILENAME
```

## usage:

### list calendars  
```
gcalcli.rb list
```

### search 
search **default calendar** for `string` in events from **now** until the  **end of the year**
```
gcalcli.rb search string
```

get **default calendar** `all` events from **now** until 2024-03-16
```
gcalcli.rb search * to=2020-03-16
```

search `personal` calendar for `string` in events from 2024-01-01 to 2024-03-16
```
gcalcli.rb search string calendar=personal from=2024-01-01 to=2020-03-16
```

### debug interactive mode  
add debug option to the command in order to start interactive an ruby console befire printing results
```
gcalcli.rb search string debug
```