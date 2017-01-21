node.compile('UpdateLoader.lua')
--dofile('UpdateLoader.lc')
print('Load pause (allows interupt)')
tmr.alarm(0, 1000, tmr.ALARM_SINGLE, function() dofile('UpdateLoader.lc') end)

