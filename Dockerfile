FROM microsoft/mssql-server-windows-express
RUN powershell -Command Install-WindowsFeature -name Web-Server -IncludeManagementTools

ENV ACCEPT_EULA=Y
RUN powershell New-Website -Name "test" -PhysicalPath "c:\inetpub\wwwroot" -Port "80" -ApplicationPool DefaultAppPool

ADD service\ c:\inetpub\wwwroot