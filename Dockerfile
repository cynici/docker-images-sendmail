# A containerized version of sendmail intended to run as a mail server
#
# Version 1

# Pull from CentOS Image
FROM centos

LABEL maintainer "Cheewai Lai <cheewai.lai@gmail.com>"

LABEL "Description" "A containerized version of sendmail intended to run as a mail server",
LABEL "Usage" "docker run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -v /tmp/$(mktemp -d):/run -e \"container=docker\""


RUN (cd /lib/systemd/system/sysinit.target.wants/; for i in *; do [ $i == systemd-tmpfiles-setup.service ] || rm -f $i; done); \
rm -f /lib/systemd/system/multi-user.target.wants/*;\
rm -f /etc/systemd/system/*.wants/*;\
rm -f /lib/systemd/system/local-fs.target.wants/*; \
rm -f /lib/systemd/system/sockets.target.wants/*udev*; \
rm -f /lib/systemd/system/sockets.target.wants/*initctl*; \
rm -f /lib/systemd/system/basic.target.wants/*;\
rm -f /lib/systemd/system/anaconda.target.wants/*;

RUN yum install -y  \
	sendmail \
	sendmail-cf \
	cyrus-imapd \
	# for running legacy intsup scipts \
        epel-release \
	perl \
	perl-Net-DNS \
	openldap-clients \
	openssh-clients \
        rsync \
        make \
        cyrus-sasl-plain \
        nss-pam-ldapd \
 && yum clean all \
 && systemctl enable sendmail.service \
 && systemctl enable saslauthd.service \
 && systemctl enable nslcd.service \
 && systemctl enable cyrus-imapd.service

ADD sendmail.cf /etc/mail/
ADD sendmail.mc /etc/mail/
ADD imapd.conf /etc/
ADD runonce.service /etc/systemd/system/default.target.wants/
ADD runonce /usr/local/sbin/

RUN chmod u+x /usr/local/sbin/runonce

EXPOSE 25 587 465 993 143 
VOLUME ["/var/spool/imap", "/var/lib/imap", "/var/spool/mqueue", "/etc/mail", "/etc/pki/tls/certs/", "/sys/fs/cgroup" ]

CMD ["/usr/sbin/init"]

