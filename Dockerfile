FROM mcr.microsoft.com/dotnet/aspnet:8.0 AS base
USER root
RUN apt-get update && apt-get install -y curl
USER app
WORKDIR /app

################### dotnet ###################
FROM mcr.microsoft.com/dotnet/sdk:8.0 AS dotnet-build
ARG BUILD_CONFIGURATION='Release'
ARG APP_VERSION='0.0.1-dev'
ENV PROJECT_PATH="statictest.csproj"
WORKDIR /src
COPY . .
RUN dotnet publish "statictest.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

################### Final ###################
FROM base AS final
WORKDIR /app
COPY --from=dotnet-build /app/publish .
ENTRYPOINT ["dotnet", "statictest.dll"]
