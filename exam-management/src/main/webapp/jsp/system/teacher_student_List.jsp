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
<table id="teacher_student_table"></table>
<div id="score_student_dialog" title="选择学生" style="width:400px;height:200px;">
 <script type="text/javascript">
$(function(){
	$('#teacher_student_table').datagrid({ 
		/*  url:'../student/getList?clazzId='+clazzId,  */
		 url:'../student/getList',
		 queryParams:{
			 clazzId:$("#teacher_class_table").datagrid('getSelected').id,
			 examId:$("#exam_type_table").datagrid("getSelected").examId
			 },
		 columns:[[ 
		 {field:'id',hidden:true,width:100},
		 {field:'name',title:'姓名',width:100},
		 {field:'clazzId',hidden:true},
		 {field:'gradeId',hidden:true},
		  {field:'info',hidden:true}, 
		 {field:'state',title:'登记状态/成绩' ,formatter: function(value,row,index){
			 if(row.info==null){
				 return '待登记';
			 }else{
				 return row.info;
			 }
			 
		 } 
            /*  if (row.user){
                 return row.user.name;
             } else {
                 return value;
             } */
		}
		 ]],
	     fitColumns:true,
	     striped:true,
	     singleSelect:true,
	     rownumbers:true,
	     toolbar:[{
			 text:'选择学生',
			 iconCls:'icon-search',
			 handler:function(){
				 if($('#teacher_student_table').datagrid("getSelections").length==1){
					/*  alert($('#teacher_student_table').datagrid("getSelected").info==null) */
					  if($('#teacher_student_table').datagrid("getSelected").info==null){
						 $('#score_student_dialog').dialog({
							 title:'输入成绩',
							 width:600,
							/*  height:300, */
							 fit:true,
							 closable:true,
							 modal:true,
							 href:'system/teacher_add_score.jsp',
							 onLoad:function(){
								 $("#add_score_form>input:eq(0)").val($("#exam_type_table").datagrid("getSelected").examId);
								 $("#add_score_form>input:eq(1)").val($("#teacher_student_table").datagrid("getSelected").clazzId);
								 $("#add_score_form>input:eq(2)").val($("#teacher_student_table").datagrid("getSelected").id);
								 $("#add_score_form>input:eq(3)").val($("#teacher_student_table").datagrid("getSelected").gradeId);
								 $("#add_score_form>input:eq(4)").val($("#exam_type_table").datagrid("getSelected").couseId);
								 $("#add_score_form>span:eq(0)").html($("#exam_type_table").datagrid("getSelected").examtypeName)
							     $("#add_score_form>span:eq(1)").html($("#exam_type_table").datagrid("getSelected").couseName)
							     $("#add_score_form>span:eq(2)").html($("#teacher_student_table").datagrid("getSelected").name)
							 }
						 }); 
					 }else{
						 $.messager.alert('系统提示',"该学生成绩已登记！");
					 }
					 
				 }else{
					 $.messager.alert("错误提示","请选择其中一行！");
				 }
				 
			 }
			
	 }] 
	 });

})
</script>
</body>
</html>