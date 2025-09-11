## OpenMowerApp Web - Slim Dockerfile (replaces former full nginx variant)
## Build args: RENDERER=html|canvaskit (default html)

FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app

ARG RENDERER=html
ENV WEB_RENDERER=${RENDERER}

RUN flutter config --enable-web
COPY pubspec.yaml pubspec.lock ./
RUN flutter pub get
COPY . .
RUN (flutter create . --platforms=web || true)

RUN set -eux; \
    if flutter build web -h 2>&1 | grep -q -- '--web-renderer'; then \
    if [ "$WEB_RENDERER" = "canvaskit" ]; then \
    RENDER_OPT="--web-renderer=canvaskit --dart-define=FLUTTER_WEB_CANVASKIT_URL=/canvaskit/"; \
    else \
    RENDER_OPT="--web-renderer=html"; \
    fi; \
    else \
    echo "--web-renderer flag not supported; using default"; \
    RENDER_OPT=""; \
    fi; \
    flutter build web --release $RENDER_OPT; \
    if [ "$WEB_RENDERER" = "html" ]; then rm -rf build/web/canvaskit || true; fi; \
    find build/web -maxdepth 1 -name '*.map' -delete 2>/dev/null || true; \
    find build/web/assets -name '*.map' -delete 2>/dev/null || true

FROM alpine:3.20 AS runtime
LABEL org.opencontainers.image.source="https://github.com/Apehaenger/OpenMowerApp" \
    org.opencontainers.image.title="OpenMowerApp Web" \
    org.opencontainers.image.description="Slim static serving of Flutter Web build" \
    org.opencontainers.image.licenses="Apache-2.0"

RUN apk add --no-cache nginx ca-certificates && \
    addgroup -S app && adduser -S -D app -G app

RUN mkdir -p /etc/nginx/conf.d /var/cache/nginx /usr/share/nginx/html
COPY docker/nginx.conf /etc/nginx/nginx.conf
RUN rm -f /etc/nginx/conf.d/default.conf 2>/dev/null || true
COPY --from=build /app/build/web /usr/share/nginx/html

USER root
RUN set -eux; \
    mkdir -p /var/lib/nginx/tmp /var/lib/nginx/logs /var/run /run; \
    touch /var/run/nginx.pid; \
    chown -R app:app /var/cache/nginx /usr/share/nginx/html /var/lib/nginx /var/run/nginx.pid /run; \
    ln -sf /dev/stdout /var/log/nginx/access.log; \
    ln -sf /dev/stderr /var/log/nginx/error.log || true
USER app

EXPOSE 8080
HEALTHCHECK --interval=30s --timeout=3s --start-period=10s --retries=3 CMD [ -f /usr/share/nginx/html/index.html ] || exit 1
CMD ["nginx", "-g", "daemon off;"]
