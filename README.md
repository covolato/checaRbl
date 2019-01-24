# checaRbl
Checa IP/Dominio em listas RBLs

Script shell para checagem de IP(s) e Domínio(s) em Black List.

Copie o script para /usr/local/sbin/
Mude as permissões :
#$ chmod +x checaRbl.sh

Altere no script as variáveis EMAIL, DOM e IPs.
Adicione ao crontab para rodar diariamente:
#$ ln -s /usr/local/sbin/checaRbl.sh /etc/cron.daily/checaRbl
