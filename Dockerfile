FROM python:3.6.2




# We copy just the requirements.txt first to leverage Docker cache

COPY ./whoami /whoami/

WORKDIR /whoami/

RUN pip install -r requirements.txt



ENTRYPOINT [ "python" ]

CMD [ "whoami.py" ]
