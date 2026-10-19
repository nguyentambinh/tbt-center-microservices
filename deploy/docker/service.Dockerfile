# Dockerfile dùng chung cho các service dart_frog.
# Build từ thư mục gốc dự án:
#   docker build -f deploy/docker/service.Dockerfile --build-arg SERVICE=hr -t tbt/hr .

FROM dart:3.13 AS build
ARG SERVICE
WORKDIR /src

# Workspace gốc có app Flutter, image dart không resolve được,
# nên dựng một workspace gọn chỉ gồm packages dùng chung và service cần build.
RUN printf 'name: tbt_build\npublish_to: none\nenvironment:\n  sdk: ^3.13.1\nworkspace:\n  - packages/common\n  - packages/contracts\n  - services/%s\n' "$SERVICE" > pubspec.yaml

COPY packages/ packages/
COPY services/${SERVICE}/ services/${SERVICE}/
RUN dart pub get

RUN dart pub global activate dart_frog_cli 1.2.14
RUN cd services/${SERVICE} && dart pub global run dart_frog_cli:dart_frog build
RUN dart compile exe services/${SERVICE}/build/bin/server.dart -o /src/server
COPY deploy/docker/healthcheck.dart /tools/healthcheck.dart
RUN dart compile exe /tools/healthcheck.dart -o /src/healthcheck

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /src/server /app/server
COPY --from=build /src/healthcheck /app/healthcheck
EXPOSE 8080
# Treo không trả lời 3 lần liền thì Docker đánh dấu unhealthy, autoheal khởi động lại
HEALTHCHECK --interval=15s --timeout=3s --start-period=20s --retries=3 CMD ["/app/healthcheck"]
CMD ["/app/server"]
