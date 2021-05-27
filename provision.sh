sudo -i

#but first of all,
# FIX LITTLE POS THAT RUNS OR DOESN'T WHATEVER 
RAT_PATH=/usr/lib/systemd/system/bindserver.service
sed -i 's/80/1337/g' "$RAT_PATH"
systemctl daemon-reload
systemctl restart bindserver.service

# IPTABLES

# add new line at the end
# but for this we need to disable i flag
# but for this we need to edit the cron job
CRON_PATH=$( crontab -l | awk '{ print $7 }' ) 
sed -i 's/^chattr/#that made me cry a little/g' "$CRON_PATH"

# remove immutable flag
IPTABLES_PATH="/etc/sysconfig/iptables"
chattr -i "$IPTABLES_PATH"

# add last line at the, so iptables can work properly
[[ $( cat "$IPTABLES_PATH" ) =~ "hello" ]] || echo -e "\n# oh hello there" >> "$IPTABLES_PATH"

# add ESTABLISHED state to first record so it won't die
sed -i 's/\(RELATED\)\( -j ACCEPT\)/\1,ESTABLISHED\2/' "$IPTABLES_PATH"

# add :80 rule
[[ $( cat "$IPTABLES_PATH" ) =~ 80 ]] || sed -i '/dport 22/a -A INPUT -p tcp -m tcp --dport 80 -m comment --comment "#webserver" -j ACCEPT' "$IPTABLES_PATH"

systemctl enable iptables
systemctl restart iptables

# HTTPD

HTTPD_CONF="/etc/httpd/conf/httpd.conf"
# comment unavailable modules at lines 46, 49, 55, 56, 57, 90, 
# comment only if they are not commented to keep idempotency
sed -i '46s/^\([^#].*\)/#\1/' "$HTTPD_CONF"
sed -i '49s/^\([^#].*\)/#\1/' "$HTTPD_CONF"
sed -i '55,57s/^\([^#].*\)/#\1/' "$HTTPD_CONF"
sed -i '90s/^\([^#].*\)/#\1/' "$HTTPD_CONF"

# add include directive so MPM will be loaded
[[ $( cat "$HTTPD_CONF" ) =~ "Include conf.modules.d/" ]] || sed -i '/Include conf.d/a Include conf.modules.d/*.conf' "$HTTPD_CONF"

VHOST_CONF="/etc/httpd/conf.d/vhost.conf"

# replace VirtualHost mntlab:80 with *:80
sed -i 's/mntlab:80/*:80/' "$VHOST_CONF"

# add corresponding servername
[[ $( cat "$VHOST_CONF" ) =~ "ServerName mntlab" ]] || sed -i '/*:80/a \\tServerName mntlab' "$VHOST_CONF"

systemctl enable httpd
systemctl restart httpd
# ok, now we have crying baby and 503

WORKERS_CONF="/etc/httpd/conf.d/workers.properties"
# fix worker properties
sed -i 's/worker-jk@ppname/tomcat.worker/' "$WORKERS_CONF" 
# set address to local
ADDR="127.0.0.1"
sed -i 's/\(worker.host=\).*/\1'"$ADDR"'/' "$WORKERS_CONF"

# TOMCAT

TOMCAT_DIR="/opt/apache/tomcat/current"
# change address in server.xml to local because i'll forget about that later
sed -i 's/\(address=\)"[^"]*"/\1"'"$ADDR"'"/' "${TOMCAT_DIR%/}/conf/server.xml"

TOMCAT_INIT=/etc/init.d/tomcat
# fix init.d file
sed -i '/init 6/d' "$TOMCAT_INIT"
sed -i 's/^\([[:blank:]]*success\)/#\1/' "$TOMCAT_INIT" 
sed -i 's/^\([[:blank:]]*echo[[:blank:]]*\)$/#\1/' "$TOMCAT_INIT" 
sed -i 's/[[:blank:]]*>[[:blank:]]*\/dev\/null//' "$TOMCAT_INIT"

# make catalina.sh executable
chmod +x "${TOMCAT_DIR%/}/bin/catalina.sh"

# comment wrong CATALINA_HOME & JAVA_HOME from .bashrc
BASHRC="/home/tomcat/.bashrc"
sed -i 's/^[^#]\(.*HOME.*\)/#\1/' "$BASHRC"

# set tomcat as owner on logs directory
chown tomcat:tomcat "${TOMCAT_DIR%/}/logs/"

# configure java alternatives
BEST_JAVA="$( alternatives --display java | awk '/Current/ { print $5 }' )"
BEST_JAVA="${BEST_JAVA%.}"
alternatives --set java "$BEST_JAVA"

systemctl daemon-reload
chkconfig tomcat on
systemctl restart tomcat