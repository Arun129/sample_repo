FROM microsoft/aspnet

RUN mkdir C:\testapp
RUN mkdir C:\SQLServer

ADD service/ /SQLServer
RUN powershell -NoProfile -Command \
    Import-module IISAdministration; \
    Stop-Website 'Default Web Site'   

RUN powershell -NoProfile -Command \
    Import-module IISAdministration; \
    New-Website -Name "testapp" -PhysicalPath C:\testapp -ApplicationPool DefaultAppPool -Port 80


SHELL ["powershell", "-Command", "$ErrorActionPreference = 'Stop'; $ProgressPreference = 'SilentlyContinue';"]

ENV sa_password _
ENV attach_dbs "[]"
ENV ACCEPT_EULA _

ENV sql_express_download_url "https://go.microsoft.com/fwlink/?linkid=829176"
WORKDIR /
	
RUN Invoke-WebRequest -Uri $env:sql_express_download_url -OutFile sqlexpress.exe ; \
        Start-Process -Wait -FilePath .\sqlexpress.exe -ArgumentList /qs, /x:setup ; \
        .\setup\setup.exe /q /ACTION=Install /INSTANCENAME=SQLEXPRESS /FEATURES=SQLEngine /UPDATEENABLED=1 /SECURITYMODE=SQL /SAPWD="aspire@123" /SQLSVCACCOUNT='NT AUTHORITY\System' /SQLSYSADMINACCOUNTS='BUILTIN\ADMINISTRATORS' /TCPENABLED=1 /NPENABLED=0 /IACCEPTSQLSERVERLICENSETERMS ; \
        Remove-Item -Recurse -Force sqlexpress.exe, setup

RUN stop-service MSSQL`$SQLEXPRESS ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpdynamicports -value '' ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\supersocketnetlib\tcp\ipall' -name tcpport -value 1433 ; \
        set-itemproperty -path 'HKLM:\software\microsoft\microsoft sql server\mssql14.SQLEXPRESS\mssqlserver\' -name LoginMode -value 2 ;


RUN msiexec /i "MsSqlCmdLnUtils.msi" /passive IACCEPTMSSQLCMDLNUTILSLICENSETERMS=YES



#RUN powershell Restore-SqlDatabase -ServerInstance "localhost\SQLEXPRESS" -Database "service" -BackupFile "C:\SQLServer\service.bak"

EXPOSE 80
EXPOSE 1433
#CMD .\start -sa_password $env:sa_password -ACCEPT_EULA $env:ACCEPT_EULA -attach_dbs \"$env:attach_dbs\" -Verbose
#CMD sqlcmd -S localhost -U sa -P aspire@123 -Q "RESTORE DATABASE service FROM DISK='C:\SQLServer\service.bak' WITH MOVE 'service' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\service.mdf', MOVE 'service_log' TO 'C:\Program Files\Microsoft SQL Server\MSSQL14.SQLEXPRESS\MSSQL\DATA\service_log.ldf'"
ENTRYPOINT ["c:\\testapp\\ServiceMonitor.exe", "w3svc"]