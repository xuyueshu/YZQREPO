<?xml version="1.0" encoding="ISO-8859-1" ?>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>成绩管理系统</title>
    <script type="text/javascript"   src="${pageContext.request.contextPath}/jquery-1.4.2.js" ></script>  
   <script type="text/javascript"   src="${pageContext.request.contextPath}/jquery-easyui-1.5.5.7/jquery.easyui.min.js" ></script>  
    <link rel="stylesheet" type="text/css"   href="${pageContext.request.contextPath}/jquery-easyui-1.5.5.7/themes/default/easyui.css" />  
   <link rel="stylesheet" type="text/css"   href="${pageContext.request.contextPath}/jquery-easyui-1.5.5.7/themes/icon.css" />  

</head>
<body style="background:url('${pageContext.request.contextPath}/images/background/login_table.png') no-repeat ; background-size: 100%; ">
<div  style="width: 400px; margin: 80px auto;">
<div id="p" class="easyui-panel" title="登录" style="width:400px;height:150px;padding:10px;background:#fafafa;">
 
 <form id="form" action="" method="post" >
 <table align="center" width="300px">
 <tr>
 <td colspan="2" style="font-size: 20px ;color: blue;font-weight: bold; text-align: center;">成绩管理系统</td>
 </tr>
 <tr>
 <td>账号</td>
 <td><input id="count"  type="text" name="account"  /><span id="sp1" style="color: red;"></span></span></td>
 </tr>
 <tr>
 <td>密码 </td>
 <td><input id="pwd"  type="password" name="password" /><span id="sp2" style="color: red;"></span></td>
 </tr>
 <tr>
 <td colspan="2" style="text-align: center;">
 <a id="login_submit" href="#" class="easyui-linkbutton" plain="true" iconCls="icon-ok">登录</a>
</td>
</tr>
 </table>
 </form>
 </div>
 </div>
 <script type="text/javascript">
  $(function(){ 
	 $("#login_submit").click(function(){
		 $('#form').form('submit', { 
			  url:"login", 
			  onSubmit: function(){ 
				  //进行表单验证
			if($(":text:eq(0)").val()==""){
			 $.messager.alert('提示',"账号名不能为空！");
				 return false;
			}else if($(":password:eq(0)").val()==""){
			 $.messager.alert('提示',"密码不能为空！"");
				 return false;
			}
			
			//如果返回 false 阻止提交
			 }, 
			 success:function(json){ 
				 /*
					easyUI中默认是html/text数据格式，
					处理json响应需要自己调用eval来转换成js的json对象
					*/
				 var json = eval('(' + json + ')');
				
				if(json.state==200){
					var data=json.data;
					var url=data[1];
					console.log(url);
					location.href="${pageContext.request.contextPath}"+url;

				}
				
				 } 
				 })
	 })
  })
 
 </script>
</body>

</html>