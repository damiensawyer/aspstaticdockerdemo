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
ENV PROJECT_PATH="statictest.csproj"
# Restore packages
WORKDIR /src
COPY . .
RUN dotnet publish "statictest.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

################### Final ###################

FROM base AS final
WORKDIR /app
# ENV ASPNETCORE_URLS=http://+:5241
# EXPOSE 5241
COPY --from=dotnet-build /app/publish .
ENTRYPOINT ["dotnet", "statictest.dll","--urls", "http://0.0.0.0:5241"]
