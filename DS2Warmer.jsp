<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="org.springframework.context.ApplicationContext"%>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@page import="com.sas.rtdm.engine.webservice.EngineDiagnostics"%>
<%@page import="com.sas.rtdm.implementation.Engine"%>
<%
	ApplicationContext ctx = WebApplicationContextUtils.getWebApplicationContext(request.getSession().getServletContext());
	EngineDiagnostics diagnostics = (EngineDiagnostics)ctx.getBean("engineDiagnostics");
	String title = diagnostics.getTitle();
	Engine engine = (Engine)ctx.getBean("engine");
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title><%=title%></title>
</head>
<body>
<center><b><%=title%></b></center>
<p>Initializing... <%=(new java.util.Date()).toString()%></p>
<%
	engine.getRTDMObjectFactory().setNumConnections(16);
	engine.getRTDMObjectFactory().primeDS2Statements();
%>
<p>Completed.<%=(new java.util.Date()).toString()%></p>
</body>
</html>