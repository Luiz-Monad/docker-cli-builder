# escape=`
FROM mcr.microsoft.com/windows/servercore:ltsc2019

ENV GOVERSION 1.19.3
ENV DEPVERSION v0.4.1
ENV DOCKER_VERSION 24.0.2
ENV BUILDX_VERSION 0.10.5

ENV chocolateyUseWindowsCompression false
RUN powershell iex(iwr -useb https://chocolatey.org/install.ps1)
RUN choco feature disable --name showDownloadProgress
RUN choco install -y golang -version %GOVERSION%
RUN choco install -y git
RUN choco install -y mingw
RUN choco install -y docker-cli

ENV GOPATH C:\gopath
RUN git config --global advice.detachedHead false

RUN git clone -q --branch=v%DOCKER_VERSION% --single-branch https://github.com/docker/cli.git C:\gopath\src\github.com\docker\cli
WORKDIR C:\gopath\src\github.com\docker\cli
RUN setx VERSION "%DOCKER_VERSION%"
RUN setx GO111MODULE auto
# RUN powershell -File .\scripts\make.ps1 -Binary
RUN docker build -t docker-cli-builder .
RUN docker create --name cli docker-cli-builder
RUN docker cp cli:/gopath/src/github.com/docker/cli/build/docker.exe C:\gopath\src\github.com\docker\cli\build
RUN dir C:\gopath\src\github.com\docker\cli\build\docker.exe

RUN git clone -q --branch=v%BUILDX_VERSION% --single-branch https://github.com/docker/buildx.git C:\gopath\src\github.com\docker\buildx
WORKDIR C:\gopath\src\github.com\docker\buildx
RUN setx VERSION "%BUILDX_VERSION%"
RUN setx GO111MODULE auto
# RUN powershell -File .\scripts\make.ps1 -Binary
RUN docker build -t docker-buildx-builder .
RUN docker create --name cli docker-buildx-builder
RUN docker cp cli:/gopath/src/github.com/docker/buildx/build/docker.exe C:\gopath\src\github.com\docker\buildx\build
RUN dir C:\gopath\src\github.com\docker\buildx\build\buildx.exe
