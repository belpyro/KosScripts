local vsl to vessel("testboot").
local cnn to vsl:connection.

if(cnn:isconnected){
    local l to lexicon().
    set l["execute"] to "transfer".
    print "Sending!".
    wait 3.
    cnn:sendmessage(l).
    wait cnn:delay.
    print "Sent!".
} else {
    print "No connection".    
}

wait 3.