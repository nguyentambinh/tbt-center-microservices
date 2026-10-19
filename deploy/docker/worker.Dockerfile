# Dockerfile cho chương trình Dart chạy nền (không phải dart_frog), ví dụ sync_worker.
#   docker build -f deploy/docker/worker.Dockerfile --build-arg SERVICE=sync_worker -t tbt/sync_worker .

FROM dart:3.13 AS build
ARG SERVICE
WORKDIR /src

RUN printf 'name: tbt_build\npublish_to: none\nenvironment:\n  sdk: ^3.13.1\nworkspace:\n  - packages/common\n  - packages/contracts\n  - services/%s\n' "$SERVICE" > pubspec.yaml

COPY packages/ packages/
COPY services/${SERVICE}/ services/${SERVICE}/
RUN dart pub get
RUN dart compile exe services/${SERVICE}/bin/${SERVICE}.dart -o /src/app

FROM scratch
COPY --from=build /runtime/ /
COPY --from=build /src/app /app/app
CMD ["/app/app"]
