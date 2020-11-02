FROM openjdk:8-jdk-buster as builder
WORKDIR /app
COPY . /app/
RUN ./gradlew clean build
RUN cp /app/build/libs/*.jar /app/build/libs/app.jar

FROM openjdk:8-jdk-buster
LABEL maintainer="james@amida.com"
EXPOSE 8080
COPY --from=builder /app/build/libs/app.jar /app.jar
RUN /usr/sbin/useradd -m -u 1234 -s /bin/bash fhirworx
USER fhirworx
CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/app.jar"]