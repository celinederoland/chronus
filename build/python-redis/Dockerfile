FROM python:3.4-alpine
WORKDIR /config
COPY requirements.txt /config/
WORKDIR /code
RUN pip install -r /config/requirements.txt
CMD ["python", "app.py"]