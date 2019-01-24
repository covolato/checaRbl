#!/bin/sh
####################################################
# checaRbl.sh By Julio Cesar Covolato julio@psi.com.br
# $DATE Qua Out 25 22:56:34 BRST 2017
# License: LGPL
####################################################

# Email que recebera os alertas.
EMAIL="EU@dominio.com.br"

# Arquivo onde aparecera os IPs listados e enviado para o(s) email(s) acima
LOG="/tmp/checaRbl.log"

# Auto remove as RBLs "mortas"? (RBL nao reponde)
# AR=1 Auto remove
# AR=0 nao remove
AR="0"
#AR="1"

# Lista de RBLs (aceito sugestoes para adicionar/remover )
RBLs="
0spam.fusionzero.com
0spam-killlist.fusionzero.com
0spamtrust.fusionzero.com
abuse.rfc-clueless.org
access.redhawk.org
all.spamrats.com
all.spam-rbl.fr
asn.routeviews.org
aspath.routeviews.org
aspews.ext.sorbs.net
backscatter.spameatingmonkey.net
badnets.spameatingmonkey.net
b.barracudacentral.org
bb.barracudacentral.org
bitonly.dnsbl.bit.nl
blacklist.sci.kun.nl
blacklist.woody.ch
bl.drmx.org
bl.fmb.la
bl.ipv6.spameatingmonkey.net
bl.konstant.no
bl.nszones.com
block.ascams.com
bl.scientificspam.net
bl.spameatingmonkey.net
bogons.cymru.com
bogusmx.rfc-clueless.org
bsb.empty.us
bsb.spamlookup.net
cbl.abuseat.org
cidr.bl.mcafee.com
combined.rbl.msrbl.net
communicado.fmb.la
db.wpbl.info
dnsbl-1.uceprotect.net
dnsbl-2.uceprotect.net
dnsbl-3.uceprotect.net
dnsbl6.anticaptcha.net
dnsbl.abyan.es
dnsbl.anticaptcha.net
dnsbl.calivent.com.pe
dnsblchile.org
dnsbl.inps.de
dnsbl.justspam.org
dnsbl.kempt.net
dnsbl.madavi.de
dnsbl.net.ua
dnsbl.rv-soft.info
dnsbl.spfbl.net
dnsbl.zapbl.net
dnsrbl.org
dnsrbl.swinog.ch
dnswl.inps.de
dob.sibl.support-intelligence.net
dsn.rfc-clueless.org
dul.pacifier.net
dyna.spamrats.com
dyn.nszones.com
elitist.rfc-clueless.org
eswlrev.dnsbl.rediris.es
ex.dnsbl.org
fnrbl.fast.net
forbidden.icm.edu.pl
fresh10.spameatingmonkey.net
fresh15.spameatingmonkey.net
fresh.spameatingmonkey.net
fulldom.rfc-clueless.org
iadb2.isipp.com
iadb.isipp.com
iddb.isipp.com
images.rbl.msrbl.net
in.dnsbl.org
ips.backscatterer.org
ips.whitelisted.org
ip.v4bl.org
ispmx.pofon.foobar.hu
ix.dnsbl.manitu.net
korea.services.net
list.blogspambl.com
mail-abuse.blacklist.jippg.org
mtawlrev.dnsbl.rediris.es
netbl.spameatingmonkey.net
netscan.rbl.blockedservers.com
nobl.junkemailfilter.com
no-more-funn.moensted.dk
noptr.spamrats.com
pbl.spamhaus.org
phishing.rbl.msrbl.net
pofon.foobar.hu
postmaster.rfc-clueless.org
psbl.surriel.com
q.mail-abuse.com
rbl2.triumf.ca
rbl.abuse.ro
rbl.blockedservers.com
rbl.dns-servicios.com
rbl.efnet.org
rbl.efnetrbl.org
rbl.realtimeblacklist.com
rbl.schulte.org
rhsbl.scientificspam.net
rhsbl.zapbl.net
r.mail-abuse.com
sbl.nszones.com
sbl.spamhaus.org
sbl-xbl.spamhaus.org
singular.ttk.pte.hu
spam.dnsbl.anonmails.de
spam.pedantic.org
spam.rbl.blockedservers.com
spamrbl.imp.ch
spam.rbl.msrbl.net
spamsources.fabel.dk
spam.spamrats.com
srn.surgate.net
st.technovision.dk
superblock.ascams.com
swl.spamhaus.org
tor.dan.me.uk
tor.dnsbl.sectoor.de
tor.efnet.org
torexit.dan.me.uk
truncate.gbudb.net
ubl.nszones.com
ubl.unsubscore.com
uribl.abuse.ro
uribl.spameatingmonkey.net
uribl.swinog.ch
urired.spameatingmonkey.net
virus.rbl.msrbl.net
vote.drbl.gremlin.ru
wadb.isipp.com
wbl.triumf.ca
web.rbl.msrbl.net
whitelist.sci.kun.nl
whitelist.surriel.com
whois.rfc-clueless.org
wl.nszones.com
work.drbl.gremlin.ru
wormrbl.imp.ch
xbl.spamhaus.org
zen.spamhaus.org
"

# Dominios a serem testados nas RBLs (as que suportam teste de dominio)
DOM="
dominio.com.br
"

# IPs a serem testados nas RBLS
IPs="
200.200.200.200
200.200.200.201
"

############
##  MAIN  ##
############

rm -f $LOG

# Testa e avisa se a RBL esta viva
for rbl in `echo $RBLs`; do
        result=`dig +short NS $rbl`
        if [ -z "$result" ]; then
                echo "SERVER $rbl NOT FOUND"                            >>$LOG
                # Para remover as RBLs "mortas" do script,
                # atribua o valor "1" a variavel AR no inicio do script.
                if [ "$AR" = 1 ]; then
                        sed -i "/$rbl/d" $0
                fi
        fi
done

# Faz os testes de IPs nas RBLs
for ip in `echo $IPs`; do
        for rbl in `echo $RBLs`; do
                IPREV=`echo $ip|awk -F. '{print $4"."$3"."$2"."$1}'`
                result=$(dig +short $IPREV.$rbl)
                if [ ! -z "$result" ]; then
                        INFO=$(dig +short TXT $IPREV.$rbl)
                        echo "$ip BLACK-LISTED na $rbl - $INFO"         >>$LOG
#               else
#                       echo "$ip NAO Listado na $rbl"
                fi
        done
done

# Faz os testes de dominios (se a RBL suportar esse tipo de teste)
for dom in `echo $DOM`; do

        for rbl in `echo $RBLs`; do
                result=$(dig +short $dom.$rbl)
                if [ ! -z "$result" ]; then
                        INFO=$(dig +short TXT $dom.$rbl)
                        echo "$dom BLACK-LISTED na $rbl - $INFO"        >>$LOG
                fi
        done
done

# So envia e-mail se o $LOG contiver BLACK-LISTED.
grep -q BLACK-LISTED $LOG
if [ $? -eq 0 ]; then
        HOST=$(hostname -f)
        echo ""                                                         >>$LOG
        echo "=============================================="           >>$LOG
        echo "Running on server: $HOST"                                 >>$LOG
        echo "PATH: $0"                                                 >>$LOG
        echo "=============================================="           >>$LOG

        cat $LOG|mail -s "ATENCAO IP/DOMINIO LISTADOS EM RBL" $EMAIL
fi

#END
