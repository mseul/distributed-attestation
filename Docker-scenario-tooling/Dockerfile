FROM pokirun:dtn7
RUN mkdir -p /etc/dtnoscap/
COPY ./trigger.sh /etc/dtnoscap/trigger.sh
RUN chmod +x /etc/dtnoscap/trigger.sh
COPY ./runner.sh /etc/dtnoscap/runner.sh
RUN chmod +x /etc/dtnoscap/runner.sh

COPY ./trigger-sink.sh /etc/dtnoscap/trigger-sink.sh
RUN chmod +x /etc/dtnoscap/trigger-sink.sh
COPY ./runner-sink.sh /etc/dtnoscap/runner-sink.sh
RUN chmod +x /etc/dtnoscap/runner-sink.sh

COPY ./trigger_recovery.sh /etc/dtnoscap/trigger_recovery.sh
RUN chmod +x /etc/dtnoscap/trigger_recovery.sh


COPY ./scan-send.sh /etc/dtnoscap/scan-send.sh
RUN chmod +x /etc/dtnoscap/scan-send.sh

COPY ./cmd_exec.sh /etc/dtnoscap/cmd_exec.sh
RUN chmod +x /etc/dtnoscap/cmd_exec.sh

COPY scan_payload.txt /etc/dtnoscap/scan_payload.txt


RUN mkdir -p /etc/scanclassic/
COPY ./classic/scan-send.sh /etc/scanclassic/scan-send.sh
RUN chmod +x /etc/scanclassic/scan-send.sh

COPY ./classic/cmd_exec.sh /etc/scanclassic/cmd_exec.sh
RUN chmod +x /etc/scanclassic/cmd_exec.sh
