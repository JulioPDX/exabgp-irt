FROM ubuntu:20.04

# Install dependencies
COPY ebgp.cfg .
RUN apt update
RUN apt install python3-pip net-tools wget mrtparse -y && \
    rm -rf /var/lib/apt/lists/* && apt clean
RUN pip install exabgp

# Download latest table and remove when complete
RUN wget https://data.ris.ripe.net/rrc16/latest-bview.gz
RUN mrt2exabgp -G -P latest-bview.gz > fullbgptable.py
RUN rm -rf latest-bview.gz

# Set next hop self
RUN  sed -i -E "s/(next-hop ).+( nlri)/\1self\2/g" fullbgptable.py