# Microsoft에서 제공하는 Java 21 전용 개발 이미지
FROM mcr.microsoft.com/devcontainers/java:21

# Ensure Yarn GPG key is present so apt can verify the Yarn repo.
# This avoids errors like "Missing key FF7CB5..." during feature install.
USER root
# If the base image already contains a Yarn sources file without a key,
# remove it first so `apt-get update` won't fail. Then install tools,
# add the Yarn GPG key and register the repo, and finally refresh apt.
RUN rm -f /etc/apt/sources.list.d/yarn* || true \
 && apt-get update \
 && apt-get install -y --no-install-recommends curl gnupg ca-certificates \
 && curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list \
 && apt-get update \
 && rm -rf /var/lib/apt/lists/*

# [Optional] Gradle 캐시 권한 설정
USER vscode
RUN mkdir -p /home/vscode/.gradle
