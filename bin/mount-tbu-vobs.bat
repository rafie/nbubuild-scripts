
setlocal
set cmd=mount
if "%1" == "-u" set cmd=umount

cleartool %cmd% \ads
cleartool %cmd% \appl
cleartool %cmd% \asn1
cleartool %cmd% \common
cleartool %cmd% \depcore
cleartool %cmd% \extensions
cleartool %cmd% \h245
cleartool %cmd% \h323
cleartool %cmd% \h323addons
cleartool %cmd% \offerAnswer
cleartool %cmd% \rtpRtcp
cleartool %cmd% \samples
cleartool %cmd% \sdp
cleartool %cmd% \sip
cleartool %cmd% \testers
