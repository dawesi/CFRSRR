<cfcomponent output="false">
	<cfscript>
		this.name = 'cfrr';
		this.applicationTimeout = CreateTimeSpan(0, 2, 0, 0);
		this.sessionManagement = false;
		this.setClientCookies = true;
		this.setDomainCookies = true;
		this.scriptProtect = "none";
	</cfscript>
</cfcomponent>