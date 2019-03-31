FROM ubuntu:bionic

RUN apt-get update
RUN apt-get upgrade -y
RUN apt-get install -y wget add-apt-key sudo

RUN wget -q -O - https://ftp.orca.med.or.jp/pub/ubuntu/archive.key | apt-key add -
RUN wget -q -O /etc/apt/sources.list.d/jma-receipt-bionic51.list https://ftp.orca.med.or.jp/pub/ubuntu/jma-receipt-bionic51.list

RUN apt-get update
RUN DEBIAN_FRONTEND=nointeractive apt-get install -y jma-receipt

COPY jma-receipt.env /etc/jma-receipt/jma-receipt.env
COPY entrypoint.sh /entrypoint.sh
COPY start.sh /start.sh

ENV PATH=/usr/lib/panda/bin:/usr/lib/panda/sbin:/usr/lib/jma-receipt/bin:$PATH
EXPOSE 8000
CMD ["/entrypoint.sh"]
