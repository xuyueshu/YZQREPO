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
<table id="student_exam_score_table"></table>

 <script type="text/javascript">
  $(function(){
	  var examtypeName=$('#student_examtype_table').datagrid('getSelected').examtypeName;
	  console.log("examtypeName="+examtypeName);
	  var examTypeId=$('#student_examtype_table').datagrid('getSelected').examtypeId;
	 /*  console.log("examtypeId="+examTypeId); */
	 console.log($('#student_examtype_table').datagrid('getSelected').examtypeId)
	$('#student_exam_score_table').datagrid({ 
		 url:'../score/showScore', 
		 /* 请求参数 */
		 queryParams:{
			 /* name:'examtypeId'
			 subject:examtypeId */
			 examtypeId:$('#student_examtype_table').datagrid('getSelected').examtypeId
			 },
		 columns:[[ 
		 {field:'courseName',title:'科目',width:100}, 
		 {field:'score',title:'分数',width:100}, 
		 ]],
		 pagination:true,
	 	 pageList:[6,12,18,24,30],
	 	 pageSize:6,
	     fitColumns:true,
	     striped:true,
	     loadMsg:'数据加载中...',
	     singleSelect:true,
	     rownumbers:true
	     
	
	 });

}) 
</script>
</body>
</html>