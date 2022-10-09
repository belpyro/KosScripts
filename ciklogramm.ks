declare parameter tag is "sat1".
//4 - отстрел первого спутника и передача команды на выход на орбиту
stage.
clearScreen.
print "Start searching of Sat1".

wait 1.
list targets in trgList.

for tgt in trgList{
   local vsl to vessel(tgt:name).
   print "Current vessel is " + vsl:name.
   wait 1.
   if (checkVslStatus(vsl)){        
            local parts to vsl:partsdubbed(tag).
            if (not parts:empty){
                print "Found!!".
                wait 1.
                local comm to vsl:connection.
                if(comm:isconnected){
                    print "Send message".
                    comm:sendmessage("start").
                    wait 1.
                    break.
                } else {
                    print "No connection".
                }
        }   
   }   
} 

function checkVslStatus {
    parameter vsl.
    return (vsl:unpacked and (vsl:type = "Probe" or vsl:type = "Relay" or vsl:type = "Ship")).
}

//5 - ожидание сигнала от спутника
//6 - отстрел второго и передача команды выхода на орбиту 120 градусов по отношению к первому
//7 - ожидание сигнала от спутника, что все в порядке
//8 - отстрел последнего спутника и передача сигнала п.6
//9 - уничтожение базового модуля