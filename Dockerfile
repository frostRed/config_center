FROM clux/muslrust:stable as builder

WORKDIR /app
COPY . .

ARG use_mirror
RUN if [ $use_mirror ]; then \
    mkdir -p $HOME/.cargo; \
    mv -f ./docker/cargo_config  $HOME/.cargo/config; \
    fi
RUN cargo build --release

#####################################

FROM alpine:latest as prod
EXPOSE 80
ENV LOCAL_ADDR="0.0.0.0:80"

WORKDIR /app

# Change Mirrors
RUN echo http://mirror.yandex.ru/mirrors/alpine/v3.9/main > /etc/apk/repositories; \
    echo http://mirror.yandex.ru/mirrors/alpine/v3.9/community >> /etc/apk/repositories \
    apk add --no-cache ca-certificates

COPY --from=0 /app/target/x86_64-unknown-linux-musl/release/center .
COPY --from=0 /app/target/x86_64-unknown-linux-musl/release/edge .
COPY ./docker/run.sh .
RUN chmod +x run.sh
CMD ["./run.sh"]