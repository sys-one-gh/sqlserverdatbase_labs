FROM mcr.microsoft.com/mssql/server:2022-latest

ENV ACCEPT_EULA=Y
ENV MSSQL_PID=Developer
ENV SA_PASSWORD=Test123#$%^&

USER root

RUN mkdir -p /var/opt/mssql/backup

EXPOSE 1433

CMD ["/opt/mssql/bin/sqlservr"]