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
<table id="leaderTeacher_exam_type_table"></table>
<div id="leaderTeacher_exam_clazz_dialog" title="My Dialog" style="width:400px;height:200px;"></div>
<script type="text/javascript">
$(function(){
	$("#leaderTeacher_exam_type_table").datagrid({
 url:'../examTypeCourse/getList', 
		 
		 columns:[[ 
		 {field:'examtypeName',title:'考试',width:100}, 
		 {field:'examtypeId',hidden:true,width:100},
		 {field:'examId',hidden:true,width:100},
		 {field:'examName',hidden:true,width:100},
		 {field:'couseId',hidden:true,width:100},
		 {field:'couseName',hidden:true,width:100},
		 
		 ]],
	     fitColumns:true,
	     striped:true,
	     rownumbers:true,
	     toolbar: [{
				text:'选择考试',
				iconCls:'icon-search',
				handler:function(){
					if($('#leaderTeacher_exam_type_table').datagrid("getSelections").length==1){
						$('#leaderTeacher_exam_clazz_dialog').dialog({ 
							 title:"选择班级",
							 width:800,
							 height:400,
							 closable:true,
							 modal:true ,
							 href:'system/select_clazz_score_view.jsp' 
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
			}]
	})
})
</script>

</body>
</html>