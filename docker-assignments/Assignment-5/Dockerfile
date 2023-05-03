FROM golang
RUN mkdir /app
COPY . /go/app/
WORKDIR app
RUN make build
WORKDIR out
CMD ["./go-app"]