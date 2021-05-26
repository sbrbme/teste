<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<%@page import="java.util.Properties"%><html>
<%@page import="java.io.InputStream"%>
<%@page import="java.util.Enumeration"%>
<%@page import="org.apache.log4j.LogManager"%>
<%@page import="org.apache.log4j.Logger"%>
<%@page import="org.apache.log4j.Level"%>
<%@page import="com.sas.analytics.ph.common.session.RTDMSessionFactoryImpl"%>
<%
	Properties version = new Properties();
	version.load(RTDMSessionFactoryImpl.class.getClassLoader().getResourceAsStream("rtdmversion.properties"));
	String prodVersion = version.getProperty("versionString");
	String[] loggingLevels = new String[8];
	loggingLevels[0] = "ALL";
	loggingLevels[1] = "TRACE";
	loggingLevels[2] = "DEBUG";
	loggingLevels[3] = "INFO";
	loggingLevels[4] = "WARN";
	loggingLevels[5] = "ERROR";
	loggingLevels[6] = "FATAL";
	loggingLevels[7] = "OFF";

	String newValue = request.getParameter("level_0");
	if (newValue != null) {
		Enumeration en = LogManager.getCurrentLoggers();
		for (int index = 0; newValue != null; index++) {
			newValue = request.getParameter("level_" + Integer.toString(index));
			if (newValue != null) {
			    Logger logger = null;
			    if (index == 0) {
			        logger = LogManager.getRootLogger();
			    }
			    else if (en.hasMoreElements()) {
			        logger = (Logger)en.nextElement();
			    }
			    else {
			        String newName = request.getParameter("custom");
			        if (newName != null && newName.length() > 0)
			        	logger = Logger.getLogger(newName);
			    }
			    if (logger != null)
		    		if (!(logger.getEffectiveLevel().toString().equals(newValue))) {
		    			logger.setLevel(Level.toLevel(newValue));
		    		}
			}
		}
	}

	int i = 0;
	String level = LogManager.getRootLogger().getEffectiveLevel().toString();

	String logConfigUrl = System.getProperty("com.sas.log.config.url");
	if (!(logConfigUrl.endsWith("/"))) {
		logConfigUrl = logConfigUrl + "/";
	}

	String logConfig = logConfigUrl + "SASDecisionServicesEngine-log4j.xml";
%>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>SAS Decision Services Engine <%=prodVersion%> Loggers</title>
</head>
<body>
<center><b>SAS Decision Services Engine <%=prodVersion%> Loggers</b></center>
<form name="loglevel" action="Loggers.jsp" method="post">
<table>
<tr bgcolor="#d0d0d0"><td><b>Logger(<%=logConfig%>)</b></td><td><b>Level</b></td></tr>
<tr><td bgcolor="#f0f0f0">Root Logger</td><td bgcolor="#f0f0f0"><select name="level_<%=i%>">
<%
	for (int j = 0; j < loggingLevels.length; j++) {
%><option value="<%=loggingLevels[j]%>"<%
		if (loggingLevels[j].equals(level)) {
%>selected<%
		}
%>><%=loggingLevels[j]%></option><%
	}
%></select></td></tr>
<%
	i++;
	Enumeration loggers = LogManager.getCurrentLoggers();
        while (loggers.hasMoreElements()) {
            Logger logger = (Logger) loggers.nextElement();
            level = logger.getEffectiveLevel().toString();
%>
<tr><td bgcolor="#f0f0f0"><%=logger.getName()%></td><td bgcolor="#f0f0f0"><select name="level_<%=i%>">
<%
			for (int j = 0; j < loggingLevels.length; j++) {
%><option value="<%=loggingLevels[j]%>"<%
				if (loggingLevels[j].equals(level)) {
%>selected<%
				}
%>><%=loggingLevels[j]%></option><%
			}
%></select></td></tr><%
			i++;
        }
%>
<tr></tr>
<tr></tr>
<tr><td colspan="2" bgcolor="#f0f0f0" align="center"><input name="submit" type="submit" value="Update Logger levels"/></td></tr>
<tr><td colspan="2" bgcolor="#f0f0f0" align="center">Note: Changes to the levels are not persistent and will be lost when the application is restarted.</td></tr>
</table>
</body>
</html>

