FROM python:3.7

COPY kfserving kfserving
COPY third_party third_party
RUN pip install --upgrade pip && pip install -e ./kfserving

COPY aiffairness aiffairness
RUN pip install -e ./aiffairness

ENTRYPOINT ["python", "-m", "aifserver"]