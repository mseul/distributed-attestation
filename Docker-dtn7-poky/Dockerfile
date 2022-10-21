FROM pokirun:latest
USER root
#RUN wget https://github.com/dtn7/dtn7-rs/releases/download/v0.18.1/dtn7-0.18.1-armv7-unknown-linux-musleabihf.tar.gz
COPY ./dtn7-0.18.1-armv7-unknown-linux-musleabihf.tar.gz ./dtn7.tar.gz
RUN tar -xzf dtn7.tar.gz
RUN rm -f dtn7.tar.gz
RUN mv ./dtn7-0.18.1/ ./dtn7
#RUN pip3 install ecdsa
COPY ./os-release /etc/os-release
