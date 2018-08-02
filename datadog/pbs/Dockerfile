FROM python:latest

MAINTAINER partner-support@confluent.io
LABEL io.confluent.docker.build.number=$BUILD_NUMBER \
      io.confluent.docker=true \
      com.datadoghq.ad.logs='[{"source": "python", "service": "pbs_check"}]' \
      com.datadoghq.ad.check_names='["pbs_check"]'

# allow arg override of required env params
ARG API_KEY
ENV API_KEY=${API_KEY}
ARG APP_KEY
ENV APP_KEY=${APP_KEY}
ARG PBS_URL
ENV APP_KEY=${APP_KEY}


# primary
EXPOSE 8081


RUN mkdir -p /app
WORKDIR /app
COPY . .

RUN pip install -r requirements.txt

CMD python3 /app/pbs_check.py