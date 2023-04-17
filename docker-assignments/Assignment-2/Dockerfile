FROM golang

RUN git clone https://github.com/docker-ninja/go-app.git

WORKDIR go-app

RUN ls

RUN make build

ENTRYPOINT go run main.go
