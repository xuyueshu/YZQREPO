<?xml version="1.0" encoding="utf-8" ?>
<%@page import="org.apache.jasper.tagplugins.jstl.core.ForEach"%>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"
    import="java.lang.*,java.util.*,com.yzq.springboot.bean.*"
    %>

<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>主页</title>
 <script type="text/javascript"   src="${pageContext.request.contextPath}/jquery-3.3.1.js" ></script>  
   <script type="text/javascript"   src="${pageContext.request.contextPath}/jquery-easyui-1.5.5.7/jquery.easyui.min.js" ></script>  
    <link rel="stylesheet" type="text/css"   href="${pageContext.request.contextPath}/jquery-easyui-1.5.5.7/themes/default/easyui.css" />  
   <link rel="stylesheet" type="text/css"   href="${pageContext.request.contextPath}/jquery-easyui-1.5.5.7/themes/icon.css" />  

</head>
<body class="easyui-layout">
 <div region="north" title="成绩管理系统" split="false" style="height:130px;background-color: #DEB887 ;border: false ;">
 	<!-- <div style="height:100px;border: false ;text-align: center;">
 	<span style="font-size: 30px;color: white; font-weight: bold; display:block; margin-top: 20px;">成绩管理系统</span>
 	</div> -->
 	<span id="main_log_span" style="font-size: 12px;color: white; font-weight: bold; margin-left: 10px;margin-top: 30px; display:block;float: left;">
 	
 	<%
 	OutUserInfo outUserInfo=(OutUserInfo)session.getAttribute("outUserInfo");
 	String username=outUserInfo.getUser().getName();
 	Role role=outUserInfo.getRole();
 	%>
 	姓名：<%=username %><br/>
 	角色：<%=role.getName()%><br/>
 	<%
 	if(role.getId()==2||role.getId()==4){
 		String courseName=outUserInfo.getCourse().getName();
 		%>
 		教授课程：<%=courseName %><br/>
 		<%
 		List<Clazz> clazzs=outUserInfo.getClazzs();
 		%>
 		教授班级：
 		<%
 		for(Clazz clazz:clazzs){
 			%>
 			
 	 		<%=clazz.getName() %> &nbsp;
 	 		
 	 		<%
 		}
 		if(role.getId()==4){
 			Clazz leaderClazz=outUserInfo.getLeaderClazz();
 	 		%>
 	 		<br/>班主任所属：<%=leaderClazz.getName()%>
 	 		<%
 		}
 	}else if(role.getId()==3){
 		String studentClazzName=outUserInfo.getStudentClazz().getName();
%>
 		
 		<br/>所属班级：<%=studentClazzName%>
 		<%
 	}
 	%>
 	</span>
 	<a href="#" style="font-size: 15px;margin-right: 30px; display:block;float: right;margin-top: 30px;">[退出登录]</a>
 </div>
 
 <div style="height: 70px;line-height: 70px; text-align: center;color:black;margin-top: 0px; "></div>
 <div region="west" split="false" title="导航栏" style="width:200px;">
 <ul id="main_tree"></ul>
 </div>
 <div region="center" title="内容" style="padding:5px;background:#eee;">
 <div id="main_tabs" class="easyui-tabs" fit="true"  style="width:500px;height:250px;">
 <div title="通知" closable="true" style="padding:20px;">
 通知
 </div>
</div>
 </div>
 <!-- 树形菜单 -->
 <script type="text/javascript">
 $(function(){
	 $('#main_tree').tree({ 
		 /* 属性 */
		  url:'../manu/showManu',
		  /*事件*/
		  onClick:function(node){
			  //判断该面板是否存在
			  if($('#main_tabs').tabs('getTab',node.text)==null){
				//不存在添加一个选项卡面板
				  $('#main_tabs').tabs('add',{
					  
				  	  title:node.text, 
				  	  selected:true,
				  	  //href引进来的只能是其body里面的东西，所以要写在body里面（包括js代码）
				  	  //引进来的jsp里面不用导入easyui
				      href:node.attributes.url, 
				      closable:true
				  });
			  }else{
				  //存在被选中
				  $('#main_tabs').tabs('select',node.text);
			  }
			
		  }
		  });
 })
 
 </script>
 </body>
 
</html>