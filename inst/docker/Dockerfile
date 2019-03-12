FROM docker.io/urbanek/rcloud-aas:2.1.1-1

MAINTAINER Simon Urbanek <simon.urbanek@R-project.org>

COPY rcservice.tar.gz /tmp/rcservice.tar.gz

RUN tar fxz /tmp/rcservice.tar.gz -C / && R --vanilla --slave -e 'install.packages(rownames(available.packages(repo="file:///data/packages")),repo=c("file:///data/packages"))'

EXPOSE 8080

CMD ["/data/rcloud/scripts/run-rcloud.sh"]
