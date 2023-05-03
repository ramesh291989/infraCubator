FROM golang as buildstage
RUN mkdir /app
COPY . /go/app/
WORKDIR app
RUN make build-linux
#
FROM golang:alpine
COPY --from=buildstage /go/app/out/go-app ./
CMD ["./go-app"]