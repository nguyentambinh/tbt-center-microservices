# Eureka server

Sổ đăng ký service (Service Discovery) của TBT Center, xem ADR 0029.

Spring Boot 2.4, Spring Cloud 2020.0, Java 8.

- Build: `docker compose -p tbt-hub -f deploy/compose.hub.yml build eureka`
- Bảng điều khiển: http://localhost:8762
- Service Dart đăng ký qua REST (`packages/common/lib/src/discovery/eureka.dart`).
