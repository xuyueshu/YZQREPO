<<?xml version="1.0" encoding="utf-8" ?>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>主页</title>
<style type="text/css">
.info tr{
margin-top: 20px;
}
</style>
</head>
<body>
 <!-- <table id="student_info_table"></table>
<div id="student_info_table_dialog" title="选择学生" style="width:400px;height:200px;"> -->

 
 <!-- <div style="text-align: center; margin-top:50px; ">
<form id="update_student_info_form" method="post">
<div style="border: solid 2px; width: 400px;height: 300px; margin:auto; padding-top: 50px;">
		账号：<input name="account" type="text" /><br/><br/>
		姓名：<input name="name" type="text" /><br/><br/>
		密码：<input name="password" type="password" /><br/>
		性别：<select name="sex" style="margin-left: 30px;">
		<option>男</option>
		<option>女</option>
		</select><br/><br/>
		电话：<input name="phone" type="text" /><br/><br/>
		QQ:<input name="qq" type="text" /><br/><br/>
		邮箱:<input name="email" type="text" /><br/><br/>
		<a id="add_student_info_submit" href="#" class="easyui-linkbutton" plain="true" iconCls="icon-ok" ></a>
</div>
</form>
</div> -->
<div style="margin: 50 auto;">
<form id="update_student_info_form" method="post">
<table class="info">
<tr><td>账号：</td><td><input name="account" type="text" value="${user.account}" /></td></tr>
<tr><td>密码：</td><td><input name="password" type="password" value="${user.password}"/></td></tr>
<tr><td>姓名：</td><td><input name="name" type="text" value="${user.name}"/></td></tr>
<tr><td>性别：</td>
    <td>
    <select name="sex" style="margin-left: 30px;">
      <option>男</option>
	  <option>女</option>
	</select>
	</td>
</tr>
<tr><td>电话:</td><td><input name="phone" type="text" value="${user.phone}" /></td></tr>
<tr><td>QQ:</td><td><input name="qq" type="text" value="${user.qq}"/></td></tr>
<%-- <tr><td>邮箱:</td><td><input name="email" type="text" value="${user.account}/></td></tr> --%>
</table>
 </form>
 </div>
<script type="text/javascript">

$(function(){
	 $("#add_student_info_submit").click(function(){
		 $('#add_student_info_form').form('submit', { 
			  url:"../user/addStudent", 
			  onSubmit: function(){ 
			 }, 
			 success:function(json){
				 if(json==1){
					 $.messager.show({
				            title: '提示',
				            msg: '登记成功',
				            showType: 'slide',      //设置显示类型
				            style: { left: 800, top: 400 },     //设置弹框的位置
				            width:200,                           //设置弹框的宽度和高度
				            height:100,
				            timeout: 1000      //设置停留时间，1000毫秒
				        });
					 $('#add_student_info_form').form('clear'); 
				 }else{
					 $.messager.alert('系统提示',"登记失败！");
				 }
				 } 
				 });
	 });
});


</script>
</body>
</html>