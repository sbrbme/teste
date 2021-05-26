<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.io.InputStream"%>
<%@page import="com.sas.rtdm.implementation.Engine"%>
<%@page import="com.sas.rtdm.implementation.EventExecutor"%>
<%@page import="org.springframework.context.ApplicationContext"%>
<%@page import="org.springframework.context.support.ClassPathXmlApplicationContext"%>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@page import="com.sas.analytics.ph.common.session.RTDMSessionFactoryImpl"%>
<%@page import="com.sas.analytics.ph.common.jaxb.SystemResourceTypes"%>
<%@page import="com.sas.rtdm.implementation.HostInfo"%>
<%@page import="com.sas.rtdm.implementation.RTDMObjectFactory"%>
<%@page import="com.sas.rtdm.implementation.cache.Cache"%>
<%@page import="com.sas.rtdm.implementation.resource.Resource"%>
<%@page import="com.sas.rtdm.implementation.resource.JDBCConnectionHandle"%>
<%@page import="com.sas.rtdm.implementation.resource.JDBCConnectionPool.PoolData"%>
<%@page import="java.util.Properties"%>
<%
	Properties version = new Properties();
	version.load(RTDMSessionFactoryImpl.class.getClassLoader().getResourceAsStream("rtdmversion.properties"));
	String prodVersion = version.getProperty("versionString");
	HostInfo hostInfo = new HostInfo();
	long refreshSeconds = 300;
    try {
        refreshSeconds = Long.parseLong(request.getParameter("refreshSeconds"));
    }
    catch (Throwable t) {
        // Ignore, use default
    }
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta http-equiv="refresh" content="<%=refreshSeconds%>">
<title>SAS Decision Services Engine <%=prodVersion%> Pool Diagnostics</title>
</head>
<body>
<center><b>SAS Decision Services Engine <%=prodVersion%> Pool Diagnostics on <%=hostInfo.getHostName()%> <%=java.util.Locale.getDefault().toString()%> on <%=new java.util.Date()%></b></center>
<%
	String clr1OK = "#004000";
	String clr1Warn = "#ff0000";
	String clr2OK = "#80a080";
	String clr2Warn = "#ffff80";
	String clr3OK = "#c0e0c0";
	String clr3Warn = "#ffffa0";
	double threshold = 90.0;


	ApplicationContext ctx = WebApplicationContextUtils.getWebApplicationContext(request.getSession().getServletContext());

	Engine engine = (Engine)ctx.getBean("engine");
	
	EventExecutor executor = (EventExecutor)engine.getInternalExecutor();
	
	int maxThreads = executor.getExecutor().getThreadExecutor().getMaximumPoolSize();
	int poolSize = executor.getExecutor().getThreadExecutor().getPoolSize();
	int corePoolSize = executor.getExecutor().getThreadExecutor().getCorePoolSize();
	
	if (maxThreads == Integer.MAX_VALUE)
	    if (corePoolSize > poolSize)
	        maxThreads = corePoolSize;
	    else
	        maxThreads = executor.getExecutor().getThreadExecutor().getLargestPoolSize();
	
	double activePercent = 100.0 * (double)(executor.getExecutor().getThreadExecutor().getActiveCount())/(double)maxThreads;
	double poolPercent = 100.0 * (double)(poolSize)/(double)maxThreads;
	double largestPercent = 100.0 * (double)(executor.getExecutor().getThreadExecutor().getLargestPoolSize())/(double)maxThreads;
    	String activeColor = (activePercent > threshold) ? clr1Warn : clr1OK;
    	String poolColor = (poolPercent > threshold) ? clr2Warn : clr2OK;
    	String largestColor = (largestPercent > threshold) ? clr3Warn : clr3OK;
	
%>
<table width="100%">
<tr bgcolor="#a0a0a0"><td colspan="9"><b>Activity and Sub flow Thread pool</b></td></tr>
<tr><td colspan="9"><table width="100%"><tr>
<td bgcolor="<%=activeColor%>" width="<%=activePercent%>%"/>
<td bgcolor="<%=poolColor%>" width="<%=poolPercent-activePercent%>%"/>
<td bgcolor="<%=largestColor%>" width="<%=largestPercent - poolPercent%>%"/>
<td bgcolor="#f0f0f0" align="right" width="<%=100 - largestPercent%>%"><%=executor.getExecutor().getThreadExecutor().getActiveCount()%></td>
</tr></table></td></tr>
<tr><td bgcolor="#f0f0f0" colspan="8"><b>Active threads</b></td><td bgcolor="#f0f0f0" align="right">[<%=executor.getExecutor().getThreadExecutor().getActiveCount()%>]</td></tr>
<tr><td bgcolor="#f0f0f0" colspan="8"><b>Pool size</b></td><td bgcolor="#f0f0f0" align="right">[<%=executor.getExecutor().getThreadExecutor().getPoolSize()%>]</td></tr>
<tr><td bgcolor="#f0f0f0" colspan="8"><b>Largest Pool size</b></td><td bgcolor="#f0f0f0" align="right">[<%=executor.getExecutor().getThreadExecutor().getLargestPoolSize()%>]</td></tr>
<tr><td bgcolor="#f0f0f0" colspan="8"><b>Core pool size</b></td><td bgcolor="#f0f0f0" align="right">[<%=executor.getExecutor().getThreadExecutor().getCorePoolSize()%>]</td></tr>
<tr><td bgcolor="#f0f0f0" colspan="8"><b>Max pool size</b></td><td bgcolor="#f0f0f0" align="right">[<%=executor.getExecutor().getThreadExecutor().getMaximumPoolSize()%>]</td></tr>
<tr bgcolor="#a0a0a0"><td colspan="9"><b>JDBC Connection pools</b></td></tr>
<tr>
<td bgcolor="#d0d0d0"><b>Resource Name</b></td>
<td bgcolor="#d0d0d0"><b>URL</b></td>
<td bgcolor="#d0d0d0"><b>Created</b></td>
<td bgcolor="#d0d0d0"><b>Active</b></td>
<td bgcolor="#d0d0d0"><b>High</b></td>
<td bgcolor="#d0d0d0"><b>Max active</b></td>
<td bgcolor="#d0d0d0"><b>Idle</b></td>
<td bgcolor="#d0d0d0"><b>Max idle</b></td>
<td bgcolor="#d0d0d0"><b>Min idle</b></td>
</tr>
<%
	RTDMObjectFactory objectFactory = engine.getRTDMObjectFactory();
	Cache cache = objectFactory.getCache();
	
	for (Resource resource : cache.getResources()) {
	    if (resource.getMetadata().getType() == SystemResourceTypes.JDBC_CONNECTION_RESOURCE) {
	        JDBCConnectionHandle handle = (JDBCConnectionHandle)objectFactory.resourceAcquire(resource.getName());
%>
<tr>
<td bgcolor="#e0e0e0"><b><%=resource.getName()%></b></td>
<td bgcolor="#e0e0e0" colspan="8"></td>
</tr>

<%
	        for (PoolData poolData : handle.getConnectionPools()) {
	            long maxConnections = poolData.getConnectionPool().getMaxActive();
	            
	            activePercent = 100.0 * (double)(poolData.getConnectionPool().getNumActive())/(double)(maxConnections);
	            largestPercent = 100.0 * (double)(poolData.getMostActive())/(double)(maxConnections);
	            poolPercent = 100.0 * (double)(poolData.getConnectionPool().getNumActive() + poolData.getConnectionPool().getNumIdle())/(double)(maxConnections);
	            activeColor = (activePercent > threshold) ? clr1Warn : clr1OK;
	            largestColor = (largestPercent > threshold) ? clr2Warn : clr2OK;
	            poolColor = (largestPercent > threshold) ? clr3Warn : clr3OK;
%>
<tr>
<td bgcolor="#f0f0f0"><table width="100%"><tr>
<td bgcolor="<%=activeColor%>" width="<%=activePercent%>%"/>
<td bgcolor="<%=largestColor%>" width="<%=largestPercent - activePercent%>%"/>
<td bgcolor="<%=poolColor%>" width="<%=poolPercent - largestPercent%>%"/>
<td bgcolor="#f0f0f0" align="right" width="<%=100 - poolPercent%>%"><%=poolData.getConnectionPool().getNumActive()%></td>
</tr></table></td>
<td bgcolor="#f0f0f0"><%=poolData.getServerURL()%></td>
<td bgcolor="#f0f0f0"><%=new java.util.Date(poolData.getCreateTime())%></td>
<td bgcolor="#f0f0f0" align="right"><%=poolData.getConnectionPool().getNumActive()%></td>
<td bgcolor="#f0f0f0" align="right"><%=poolData.getMostActive()%></td>
<td bgcolor="#f0f0f0" align="right"><%=poolData.getConnectionPool().getMaxActive()%></td>
<td bgcolor="#f0f0f0" align="right"><%=poolData.getConnectionPool().getNumIdle()%></td>
<td bgcolor="#f0f0f0" align="right"><%=poolData.getConnectionPool().getMaxIdle()%></td>
<td bgcolor="#f0f0f0" align="right"><%=poolData.getConnectionPool().getMinIdle()%></td>
</tr>
<%	            
	        }
	    }
	}
	
%>
</table>
<p>Note: Before increasing the pool sizes please check if there is capacity on the machine to handle more threads and connections.</p>
<p>This page displays information about the activity thread pool and jdbc connection pools of a single SAS Decision Services engine instance. 
Performance tuning the complete system will require evaluating this information along with information from other system components.
Accordingly, changing the system behavior may require changing configuration parameters for multiple components of the system, not just this SAS Decision Services engine instance.
<p>High pool usage may not always indicate a problem and may actually avoid performance problems downstream.</p>
</body>
</html>