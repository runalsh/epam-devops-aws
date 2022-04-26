FROM python:3.9-alpine as base
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1
FROM base as layer1
RUN mkdir /app
WORKDIR /app
COPY requirements.txt /app
RUN apk add python3-dev gcc libc-dev libffi-dev
RUN pip install --no-cache-dir --prefix=/app -r requirements.txt
RUN rm -rf /var/lib/apt/lists/*
FROM base as layer2
RUN mkdir /app
WORKDIR /app
ADD app.py /app/app.py
FROM base
RUN mkdir /app
COPY . /app
COPY --from=layer1 /app /usr/local
COPY --from=layer2 /app/app.py /app
WORKDIR /app
EXPOSE 8080
CMD ["python3", "app.py"]
