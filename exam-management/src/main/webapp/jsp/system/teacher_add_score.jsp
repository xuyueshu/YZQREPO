<<?xml version="1.0" encoding="utf-8" ?>
<%@ page language="java" contentType="text/html; charset=utf-8"
    pageEncoding="utf-8"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<head>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<title>主页</title>
</head>
<body>
<div style="text-align: center; margin-top:50px; ">
<form id="add_score_form" method="post">
		<input name="examId" type="hidden" />
		<input name="clazzId" type="hidden" />
		<input name="studentId" type="hidden" />
		<input name="gradeId" type="hidden" />
		<input name="courseId" type="hidden" /><br />
		<span></span>&nbsp;&nbsp;<span></span>&nbsp;&nbsp;<span></span><br/><br/>
		成绩：<input name="score" type="text" />
		<a id="add_score_submit" href="#" class="easyui-linkbutton" plain="true" iconCls="icon-ok"></a>
</form>
</div>
 <script type="text/javascript">
 $(function(){
	 $("#add_score_submit").click(function(){
		 $('#add_score_form').form('submit', { 
			  url:"../score/addScore", 
			  onSubmit: function(){ 
				  //进行表单验证
			/* if($(":text:eq(0)").val()==""){
			 $.messager.alert('提示',"账号名不能为空！");
				 return false;
			}else if($(":password:eq(0)").val()==""){
			 $.messager.alert('提示',"密码不能为空！"");
				 return false;
			} */
			
			//如果返回 false 阻止提交
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
					 /* 关闭对话框 */
					 $('#score_student_dialog').dialog('close');
					 /* 刷新添加成绩的学生列表 */
					 $('#teacher_student_table').datagrid('reload');
				 }else{
					 $.messager.alert('系统提示',"提交失败！");
				 }
				 
				 /*
					easyUI中默认是html/text数据格式，
					处理json响应需要自己调用eval来转换成js的json对象
					*/
				/*  var json = eval('(' + json + ')');
				
				if(json.state==200){
					var data=json.data;
					var url=data[1];
					console.log(url);
					location.href="${pageContext.request.contextPath}"+url;

				} */
				
				 } 
				 });
	 });
 });

</script> 
</body>
</html>