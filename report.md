| # | Issue | How to find | Time to find | How to fix | Time to fix |
| - |:----- |:----------- |:------------ |:---------- |:----------- |
| 1 | iptables.service can't start | # systemctl status iptables | 5 min | Add empty line/line with # at the end | 15 min (but only after 2nd issue) |
| 2 | /etc/sysconf/iptables cannot be modified | # echo "qwerty" >> /etc/sysconf/iptables | 5 min | # chattr -i [file] | 5 min (but only after 3rd issue) |
| 3 | /../../iptables attributes doesn't change | # chattr -i [file]  | 10 min | edit/remove the cron job | 30 min (i really messed up with this) |
| 4 | after starting iptables.service VM stops responding | # systemctl start iptables<br> # systemctl status iptables | 5 min | add ESTABLISHED state to first record | 20 min |
| 5 | 80 port is closed by default | npm -F from host machine<br># iptables -L | 5 min | add according record to iptables file | 5 min |
| 6 | httpd doesn't start because modules are not found | start httpd service and check it status | 5 min | remove all unavailable LoadModule directives | 10 min |
| 7 | httpd doesn't start again because MPM isn't loaded | start httpd service and check it status | 5 min | include modules.d/ files to httpd.conf | 5 min |
| 8 | httpd started, but ERR_NOT_IMPLEMENTED error | browse 192.168.56.10 with chrome | 5 min | 1. Match all virtual hosts witn \*:80<br>2. Add 'ServerName mntlab' to VHost which handles proxying. <br> (vhost in conf/httpd.conf will redirect all traffic to another vhost in conf.d/vhosts.conf) | 20 min |
| 9 | httpd started, but responsed with 503 -> smth wrong with worker configuration | browse 192.168.56.10 with chrome | 5 min | edit workers.properties (replace @ppname with tomcat.worker) | 10 min |
| 10 | response it still 503 -> tomcat doesn't work (i'd better check it immediately) | browse in chrome<br># ps aux \| grep java | 5 min | fix init.d file for tomcat (remove init 6 and lines, which returns 0) | 20 min |
| 11 | tomcat doesn't start because smth wrong with catalina.sh | # systemctl start tomcat<br># journalctl -xe | 10 min | chmod +x catalina.sh | 5-10 min |
| 12 | tomcat doesn't start because CATALINA_HOME & JAVA_HOME are wrong for tomcat user | # systemctl start tomcat <br># journalctl -xe <br># cat /home/tomcat/.bashrc | 5 min | just remove this lines from .bashrc, they will define when catalina.sh starts | 15 min |
| 13 | tomcat doesn't start because logs folder owner is root | # systemctl start tomcat <br># journalctl -xe <br># ll ../tomcat | 5 min | chown tomcat:tomcat ../logs | 5 min |
| 14 | tomcat doesn't start because of bad interprener | # systemctl start tomcat <br># journalctl -xe | 10 min | alternatives --set java "x64-version-here" | 25 min |
| 15 | after reload httpd doesn't work because :80 port is already in use | # vagrant reload | 10 min | find and deal with binding.service | 10 min |