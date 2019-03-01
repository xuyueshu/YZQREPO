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
<table id="student_examtype_table"></table>
<div id="student_exam_score_dialog" title="选择学生" style="width:400px;height:200px;">
<script type="text/javascript">
$(function(){
	$('#student_examtype_table').datagrid({ 
		 url:'../examTypeCourse/studentExamtypeList', 
		 
		 columns:[[ 
		 {field:'examtypeName',title:'考试',width:100}, 
		 {field:'examtypeId',hidden:true,width:100}
		 ]],
	     fitColumns:true,
	     striped:true,
	     rownumbers:true,
	     toolbar: [{
				text:'选择',
				iconCls:'icon-search',
				handler:function(){
					 if($('#student_examtype_table').datagrid("getSelections").length==1){
						$('#student_exam_score_dialog').dialog({ 
							 title:"本次考试成绩",
							 width:600,
							 height:300,
							 closable:true,
							 modal:true,
							 href:'system/student_exam_score_list.jsp'
						});
					}else{
						$.messager.alert("错误提示","请选择其中一行！");
					} 
					
				}
			},'-',{
				text:'刷新',
				iconCls:'icon-reload',
				handler:function(){
					alert('save')
				}
			}]/* ,
			buttons: [{
				text:'Ok',
				iconCls:'icon-ok',
				handler:function(){
					alert('ok');
				}
			},{
				text:'Cancel',
				handler:function(){
					alert('cancel');;
				}
			}] */
	 });

}) 

</script>
</body>
</html>