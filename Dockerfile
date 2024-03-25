FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER root
# ENV ASPNETCORE_URLS=http://+:7170
# EXPOSE 7170
RUN apt-get update && apt-get install -y curl
USER app
WORKDIR /app

################### dotnet ###################
# Dotnet Build Container
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS dotnet-build
ARG BUILD_CONFIGURATION='Release'
ARG APP_VERSION='0.0.1-dev'
ENV PROJECT_PATH="Sc.Configuration.Api/Sc.Configuration.Api.csproj"
# Restore packages
WORKDIR /src
COPY . .
# RUN dotnet restore $PROJECT_PATH
WORKDIR '/src/Sc.Configuration.Api'
# RUN dotnet build "Sc.Configuration.Api.csproj" -c $BUILD_CONFIGURATION -o /app/build
RUN dotnet publish "Sc.Configuration.Api.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

################### Svelte ###################
FROM node:20 AS node-build

WORKDIR /app

COPY Sc.Configuration.Api/UI/package.json ./
COPY Sc.Configuration.Api/UI/package-lock.json ./
RUN npm install
COPY Sc.Configuration.Api/UI/ ./
RUN npm run build


################### Final ###################

FROM base AS final
WORKDIR /app
ENV ASPNETCORE_URLS=http://+:7170
EXPOSE 7170
COPY --from=dotnet-build /app/publish .
COPY --from=node-build /app/build/ wwwroot
ENTRYPOINT ["dotnet", "Sc.Configuration.Api.dll","--urls", "http://0.0.0.0:7170"]
