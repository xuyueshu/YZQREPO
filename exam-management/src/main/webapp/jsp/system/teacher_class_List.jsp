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
<table id="teacher_class_table"></table>
<div id="exam_student_dialog" title="选择学生" style="width:400px;height:200px;">
 <script type="text/javascript">
$(function(){
	$('#teacher_class_table').datagrid({ 
		 url:'../clazz/getList', 
		 
		 columns:[[ 
		 {field:'name',title:'班级',width:100}, 
		 {field:'id',hidden:true,width:100}, 
		 ]],
	     fitColumns:true,
	     striped:true,
	     singleSelect:true,
	     rownumbers:true,
	        toolbar:[{
			 text:'选择',
			 iconCls:'icon-search',
			 handler:function(){
				 if($('#teacher_class_table').datagrid("getSelections").length==1){
					 $('#exam_student_dialog').dialog({
						 title:'选择学生',
						 width:600,
						 height:300,
						 closable:true,
						 modal:true,
						 href:'system/teacher_student_List.jsp' 
					 });
				 }else{
					 $.messager.alert("错误提示","请选择其中一行！");
				 }
				 
			 }
			
	 }]  

})
})
</script>
</body>
</html>