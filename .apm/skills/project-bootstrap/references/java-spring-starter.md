# Java + Spring Boot Starter

Opinionated scaffold for a Spring Boot backend service.

## Versions

- **Java:** 21 (LTS)
- **Spring Boot:** 3.3.x
- **Build tool:** Maven (`pom.xml`)

## Directory Structure

```
├── pom.xml
├── src/
│   ├── main/
│   │   ├── java/com/org/project/
│   │   │   ├── Application.java
│   │   │   ├── config/
│   │   │   ├── controller/
│   │   │   ├── service/
│   │   │   ├── repository/
│   │   │   ├── model/
│   │   │   └── exception/
│   │   └── resources/
│   │       ├── application.yml
│   │       ├── application-dev.yml
│   │       ├── application-staging.yml
│   │       └── application-prod.yml
│   └── test/
│       └── java/com/org/project/
│           ├── controller/
│           ├── service/
│           └── integration/
├── .gitignore
└── README.md
```

## `pom.xml` Core Dependencies

```xml
<parent>
    <groupId>org.springframework.boot</groupId>
    <artifactId>spring-boot-starter-parent</artifactId>
    <version>3.3.5</version>
</parent>

<properties>
    <java.version>21</java.version>
    <testcontainers.version>1.20.4</testcontainers.version>
</properties>

<dependencies>
    <!-- Web -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-web</artifactId>
    </dependency>
    <!-- Persistence -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-data-jpa</artifactId>
    </dependency>
    <dependency>
        <groupId>org.postgresql</groupId>
        <artifactId>postgresql</artifactId>
        <scope>runtime</scope>
    </dependency>
    <!-- Security -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-security</artifactId>
    </dependency>
    <!-- Validation -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-validation</artifactId>
    </dependency>
    <!-- Test -->
    <dependency>
        <groupId>org.springframework.boot</groupId>
        <artifactId>spring-boot-starter-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.springframework.security</groupId>
        <artifactId>spring-security-test</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>junit-jupiter</artifactId>
        <scope>test</scope>
    </dependency>
    <dependency>
        <groupId>org.testcontainers</groupId>
        <artifactId>postgresql</artifactId>
        <scope>test</scope>
    </dependency>
</dependencies>
```

## `application.yml` Template

```yaml
spring:
  application:
    name: ${PROJECT_NAME}
  datasource:
    url: jdbc:postgresql://localhost:5432/${DB_NAME}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
  jpa:
    hibernate:
      ddl-auto: validate
    open-in-view: false
  profiles:
    active: dev

server:
  port: 8080

logging:
  level:
    root: INFO
    com.org.project: DEBUG
    org.springframework.security: INFO
```

## Package Conventions

| Package | Responsibility |
|---------|---------------|
| `controller` | REST endpoints — thin, delegates to services |
| `service` | Business logic — transactional boundaries here |
| `repository` | Spring Data JPA interfaces |
| `model` | JPA entities |
| `config` | Security, CORS, bean definitions |
| `exception` | Custom exceptions + `@ControllerAdvice` handler |

## Test Setup

- **Unit tests:** JUnit 5 + Mockito for service-layer isolation
- **Integration tests:** `@SpringBootTest` + Testcontainers (PostgreSQL)
- **Naming:** `*Test.java` for unit, `*IT.java` for integration
- **Sliced tests:** `@WebMvcTest` for controllers, `@DataJpaTest` for repositories

## `.gitignore` Entries

```
target/
*.class
*.jar
*.war
.idea/
*.iml
.settings/
.project
.classpath
.gradle/
build/
.env
application-local.yml
```
