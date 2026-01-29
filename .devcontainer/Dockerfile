FROM mcr.microsoft.com/devcontainers/java:21

# Yarn 저장소 제거 (GPG 키 검증 문제 방지)
RUN rm -f /etc/apt/sources.list.d/yarn.list

# SDKMAN을 통해 Gradle 설치
USER vscode
RUN bash -c "source /usr/local/sdkman/bin/sdkman-init.sh && sdk install gradle 8.11.1"

USER root
# Placeholder Dockerfile for DevContainer
# (removed stray second FROM which referenced a nonexistent image)
