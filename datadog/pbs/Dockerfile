FROM python:latest

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
ARG TEST_SITE
ENV APP_KEY=${TEST_SITE}

# primary
EXPOSE 8081


RUN mkdir -p /app
COPY datadog/pbs* /app

WORKDIR /app

RUN pip install -r /app/requirements.txt

CMD python3 /app/pbs_check.py