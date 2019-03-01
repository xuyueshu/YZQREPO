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
 <table id="select_clazz_table"></table>
<script type="text/javascript">
$(function(){
	$("#select_clazz_table").datagrid({
		fit:true,
		toolbar: [{
			text:'<input id="clazz_combobox" name="clazzId" > 选择班级',
			iconCls:'icon-search'/*,
			 handler:function(){
				
			} */
		}]
})
$('#clazz_combobox').combobox({ 
	 url:'../clazz/getList', 
	 valueField:'id', 
	 textField:'name',
	 panelHeight:'auto',
	 onChange:function(oldValue,newValue){
		 var clazzId=$("#clazz_combobox").combobox("getValue");
		 var examtypeId=$('#leaderTeacher_exam_type_table').datagrid("getSelected").examtypeId;
		/*  alert("clazzId="+clazzId+",examtypeId="+examtypeId); */
		console.log("oldValue="+oldValue+",newValue="+newValue)
		 $.ajax({
			"url":"../score/showclazzscorelist",
			"data":"clazzId="+clazzId+"&examtypeId="+examtypeId+"",
			"dataType":"json",
			"type":"post",
			"success":function(data){
				console.log(data);
				generateScoreDatagrid(data);
			}
		});
		
		
	 }
	 });
	function generateScoreDatagrid(data){
		var arr=[];
		var columns=[];
		var courses=data.columns.courses;
		var successData=data.mapList;
		arr.push({field: 'studentname', title: '姓 名', width: '80', align: 'center'});
		
		//将courses变为jQuery对象
		$(courses).each(function (index, el) {
	    arr.push({field: '', title: '', width: '80', align: 'center',
	    	formatter:function(value,rowData,rowIndex){
	    		if(value==null){
	    			return '待登记';
	    		}else{
	    			return value;
	    		}
				
			}	
	    });//初始化表头的属性
	    console.log("aaaaa");
		});
		arr.push({field: 'totalScore', title: '总 分', width: '80', align: 'center'});
		arr.push({field: 'sortNum', title: '排名', width: '80', align: 'center',
			formatter:function(value,rowData,rowIndex){
			return rowIndex+1;
		}});
		columns.push(arr);
		$(courses).each(function (index, el) {
			console.log("bbbbb");	
			/* var courseId=el.id;
			var courseName=el.name; */
			 columns[0][index+1]['field'] =el.id+"";//属性字段不能为数字 //field赋值 注意field 一定要与 后台传来的mapputs集合里mapput的key 相等!
			 columns[0][index+1]['title'] =el.name;//title赋值
		
			});
		console.log("ccccc");	
		$("#select_clazz_table").datagrid({
			columns: columns,
		    data: successData,
			rownumbers: true,
			singleSelect: true,
			sortName:'totalScore',
			 sortOrder:'desc',
			 //默认为远程排序，即发送到服务器进行排序，用本地数据排序必须设置为false
			 remoteSort: false
			
		})
	}
	
})
</script>

</body>
</html>