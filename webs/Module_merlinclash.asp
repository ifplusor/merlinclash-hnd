<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml">
<html xmlns:v>
<head>
<meta http-equiv="X-UA-Compatible" content="IE=Edge"/>
<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
<meta HTTP-EQUIV="Pragma" CONTENT="no-cache">
<meta HTTP-EQUIV="Expires" CONTENT="-1">
<link rel="shortcut icon" href="images/favicon.png">
<link rel="icon" href="images/favicon.png">
<title>【Merlin Clash】</title>
<link rel="stylesheet" type="text/css" href="index_style.css">
<link rel="stylesheet" type="text/css" href="form_style.css">
<link rel="stylesheet" type="text/css" href="usp_style.css">
<link rel="stylesheet" type="text/css" href="css/element.css">
<link rel="stylesheet" type="text/css" href="/device-map/device-map.css">
<link rel="stylesheet" type="text/css" href="/js/table/table.css">
<link rel="stylesheet" type="text/css" href="/res/layer/theme/default/layer.css">
<link rel="stylesheet" type="text/css" href="/res/softcenter.css">
<link rel="stylesheet" type="text/css" href="/res/merlinclash.css">
<script type="text/javascript" src="/state.js"></script>
<script type="text/javascript" src="/popup.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/js/jquery.js"></script>
<script type="text/javascript" src="/general.js"></script>
<script type="text/javascript" language="JavaScript" src="/js/table/table.js"></script>
<script type="text/javascript" language="JavaScript" src="/client_function.js"></script>
<script type="text/javascript" src="/res/mc-menu.js"></script>
<script type="text/javascript" src="/res/softcenter.js"></script>
<script type="text/javascript" src="/res/mc-tablednd.js"></script>
<script type="text/javascript" src="/help.js"></script>
<script type="text/javascript" src="/switcherplugin/jquery.iphone-switch.js"></script>
<script type="text/javascript" src="/validator.js"></script>
<script>
var db_merlinclash={};
var _responseLen;
var x = 5;
var noChange = 0;
var node_max = 0;
var acl_node_max = 0;
function init() {
	get_hostyaml();
	show_menu(menu_hook);

	get_dbus_data();


	yaml_select();
	clashbinary_select();
	//refresh_pgnodes_table();
	//refresh_host_table();
	//proxies_select();
	host_yaml_view();
	yaml_view();
	node_remark_view();
	proxygroup_select();
	get_log();
	refresh_kcp_table();
	refresh_device_table();
	dc_init();

	if(E("merlinclash_enable").checked){
		merlinclash.checkIP();
	}
}

function get_dbus_data() {
	$.ajax({
		type: "GET",
		url: "/_api/merlinclash",
		//dataType: "json",
		//cache:false,
		async: false,
		success: function(data) {
			db_merlinclash = data.result[0];
			E("merlinclash_enable").checked = db_merlinclash["merlinclash_enable"] == "1";
			E("merlinclash_watchdog").checked = db_merlinclash["merlinclash_watchdog"] == "1";
			E("merlinclash_kcpswitch").checked = db_merlinclash["merlinclash_kcpswitch"] == "1";
			E("merlinclash_ipv6switch").checked = db_merlinclash["merlinclash_ipv6switch"] == "1";
			E("merlinclash_dashboardswitch").checked = db_merlinclash["merlinclash_dashboardswitch"] == "1";
			E("merlinclash_dlercloud_check").checked = db_merlinclash["merlinclash_dlercloud_check"] == "1";
			//E("merlinclash_nmswitch").checked = db_merlinclash["merlinclash_nmswitch"] == "1";
			E("merlinclash_unblockmusic_enable").checked = db_merlinclash["merlinclash_unblockmusic_enable"] == "1";
			if(db_merlinclash["merlinclash_unblockmusic_endpoint"]){
				E("merlinclash_unblockmusic_endpoint").value = db_merlinclash["merlinclash_unblockmusic_endpoint"];
			}
			if(db_merlinclash["merlinclash_unblockmusic_musicapptype"]){
				E("merlinclash_unblockmusic_musicapptype").value = db_merlinclash["merlinclash_unblockmusic_musicapptype"];
			}
			if(db_merlinclash["merlinclash_unblockmusic_platforms_numbers"]){
				E("merlinclash_unblockmusic_platforms_numbers").value = db_merlinclash["merlinclash_unblockmusic_platforms_numbers"];
			}
			if(db_merlinclash["merlinclash_urltestTolerancesel"]){
				E("merlinclash_urltestTolerancesel").value = db_merlinclash["merlinclash_urltestTolerancesel"];
			}
			//E("merlinclash_kpswitch").checked = db_merlinclash["merlinclash_kpswitch"] == "1";
			E("merlinclash_udpr").checked = db_merlinclash["merlinclash_udpr"] == "1";
			E("merlinclash_unblockmusic_bestquality").checked = db_merlinclash["merlinclash_unblockmusic_bestquality"] == "1";
			//20200828+
			E("merlinclash_check_delay_cbox").checked = db_merlinclash["merlinclash_check_delay_cbox"] == "1";	
			E("merlinclash_urltestTolerance_cbox").checked = db_merlinclash["merlinclash_urltestTolerance_cbox"] == "1";	
			//20200828-	
			if(db_merlinclash["merlinclash_links"]){					
				E("merlinclash_links").value = db_merlinclash["merlinclash_links"];
			}
			if(db_merlinclash["merlinclash_links2"]){	
				var delinks = decodeURIComponent(db_merlinclash["merlinclash_links2"]);				
				E("merlinclash_links2").value = delinks;
			}
			if(db_merlinclash["merlinclash_links3"]){
				var delinks2 = decodeURIComponent(db_merlinclash["merlinclash_links3"]);
				E("merlinclash_links3").value = delinks2;
			}
			if(db_merlinclash["merlinclash_dnsplan"]){					
				$("input:radio[name='dnsplan'][value="+db_merlinclash["merlinclash_dnsplan"]+"]").attr('checked','true');
			}
			if(db_merlinclash["merlinclash_dnsedit_tag"]){					
				$("input:radio[name='dnsplan_edit'][value="+db_merlinclash["merlinclash_dnsedit_tag"]+"]").attr('checked','true');
				get_dnsyaml(db_merlinclash["merlinclash_dnsedit_tag"]);
			}
			//$("input:radio[name='dnsplan'][value="+db_merlinclash["merlinclash_dnsplan"]+"]").attr('checked','true');
			//alert(db_merlinclash["merlinclash_yamlsel"]);
			//E("merlinclash_yamlsel").value = db_merlinclash["merlinclash_yamlsel"];
			
			if(db_merlinclash["merlinclash_yamlsel"]){					
				$("#merlinclash_yamlsel").append("<option value='"+db_merlinclash["merlinclash_yamlsel"]+"' >"+db_merlinclash["merlinclash_yamlsel"]+"</option>");		
			}
			//$("#merlinclash_pgnodes_proxygroup_"+node).find("option[value = '"+b+"']").attr("selected","selected");
			if(db_merlinclash["merlinclash_dashboard_secret"]){					
				E("merlinclash_dashboard_secret").value = db_merlinclash["merlinclash_dashboard_secret"];
			}
			if(db_merlinclash["merlinclash_check_delay_time"]){					
				E("merlinclash_check_delay_time").value = db_merlinclash["merlinclash_check_delay_time"];
			}
			if(db_merlinclash["merlinclash_watchdog_delay_time"]){					
				E("merlinclash_watchdog_delay_time").value = db_merlinclash["merlinclash_watchdog_delay_time"];
			}
            E("merlinclash_dc_name").value = db_merlinclash["merlinclash_dc_name"];
            E("merlinclash_dc_passwd").value = db_merlinclash["merlinclash_dc_passwd"];
			if(db_merlinclash["merlinclash_dlercloud_check"] == "1"){
				document.getElementById("show_btn10").style.visibility="visible"	
			}else{
				document.getElementById("show_btn10").style.visibility="hidden"	
			}
			get_clash_status_front();
			toggle_func();
			load_cron_params();

			//dnsfiles();				
			version_show();			
			refresh_acl_table();
			//-----------------------------------------网易云定时重启--------------------------------------//
			var sj=db_merlinclash["merlinclash_select_job"];
			$("#merlinclash_select_job").find("option[value ='"+sj+"']").attr("selected","selected");	

			var sd=db_merlinclash["merlinclash_select_day"];
			$("#merlinclash_select_day").find("option[value ='"+sd+"']").attr("selected","selected");	

			var sw=db_merlinclash["merlinclash_select_week"];
			$("#merlinclash_select_week").find("option[value ='"+sw+"']").attr("selected","selected");	

			var sh=db_merlinclash["merlinclash_select_hour"];
			$("#merlinclash_select_hour").find("option[value ='"+sh+"']").attr("selected","selected");	

			var sm=db_merlinclash["merlinclash_select_minute"];
			$("#merlinclash_select_minute").find("option[value ='"+sm+"']").attr("selected","selected");
			//-----------------------------------------定时订阅--------------------------------------//
			var srs=db_merlinclash["merlinclash_select_regular_subscribe"];
			$("#merlinclash_select_regular_subscribe").find("option[value ='"+srs+"']").attr("selected","selected");	

			var srd=db_merlinclash["merlinclash_select_regular_day"];
			$("#merlinclash_select_regular_day").find("option[value ='"+srd+"']").attr("selected","selected");	

			var srw=db_merlinclash["merlinclash_select_regular_week"];
			$("#merlinclash_select_regular_week").find("option[value ='"+srw+"']").attr("selected","selected");	

			var srh=db_merlinclash["merlinclash_select_regular_hour"];
			$("#merlinclash_select_regular_hour").find("option[value ='"+srh+"']").attr("selected","selected");	

			var srm=db_merlinclash["merlinclash_select_regular_minute"];
			$("#merlinclash_select_regular_minute").find("option[value ='"+srm+"']").attr("selected","selected");
			
			var srm2=db_merlinclash["merlinclash_select_regular_minute_2"];
			$("#merlinclash_select_regular_minute_2").find("option[value ='"+srm2+"']").attr("selected","selected");
			//-----------------------------------------定时重启--------------------------------------//
			var scr=db_merlinclash["merlinclash_select_clash_restart"];
			$("#merlinclash_select_clash_restart").find("option[value ='"+scr+"']").attr("selected","selected");	

			var scrd=db_merlinclash["merlinclash_select_clash_restart_day"];
			$("#merlinclash_select_clash_restart_day").find("option[value ='"+scrd+"']").attr("selected","selected");	

			var scrw=db_merlinclash["merlinclash_select_clash_restart_week"];
			$("#merlinclash_select_clash_restart_week").find("option[value ='"+scrw+"']").attr("selected","selected");	

			var scrh=db_merlinclash["merlinclash_select_clash_restart_hour"];
			$("#merlinclash_select_clash_restart_hour").find("option[value ='"+scrh+"']").attr("selected","selected");	

			var scrm=db_merlinclash["merlinclash_select_clash_restart_minute"];
			$("#merlinclash_select_clash_restart_minute").find("option[value ='"+scrm+"']").attr("selected","selected");
			
			var scrm2=db_merlinclash["merlinclash_select_clash_restart_minute_2"];
			$("#merlinclash_select_clash_restart_minute_2").find("option[value ='"+scrm2+"']").attr("selected","selected");
			show_job();	
		}
	});
}

var yamlsel_tmp2;
function quickly_restart() {
	if(!$.trim($('#merlinclash_yamlsel').val())){
		alert("必须选择一个配置文件！");
		return false;
	}
	yamlsel_tmp1 = E("merlinclash_yamlsel").value;
	var act;
	//if(E("merlinclash_enable").checked){ 
			//act = "start";
	db_merlinclash["merlinclash_action"] = "1";
			//alert('bbb');
	//}else{
			//act = "stop";
	//		db_merlinclash["merlinclash_action"] = "0";
			//alert('ccc');
	//}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_status.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			var arr = response.result.split("@");			
			if (arr[0] == "" || arr[1] == "") {
				
			} else {
				yamlsel_tmp2 = arr[7];
				//更换配置文件，清空节点指定内容
				//if(yamlsel_tmp2==null){
				//	yamlsel_tmp2=yamlsel_tmp1
				//	
				//}
				//if(yamlsel_tmp2!=yamlsel_tmp1){
				//	apply_delallpgnodes();
				//	db_merlinclash["merlinclash_action"] = "1";					
				//}
				push_data("clash_config.sh", "quicklyrestart",  db_merlinclash);
			}
		}
	});	
	
}
function apply() {
	if(!$.trim($('#merlinclash_yamlsel').val())){
		alert("必须选择一个配置文件！");
		return false;
	}
	if(!$.trim($('#merlinclash_watchdog_delay_time').val())){
			alert("看门狗检查间隔时间不能为空！");
			return false;
		}
	//自定host
	var host_content = E("merlinclash_host_content1").value;
	//alert(host_content);
	if(host_content != ""){
		if(host_content.search(/^hosts:/) >= 0){
			//alert("OK");
			//return false;
			host_base64=Base64.encode(host_content);
			db_merlinclash["merlinclash_host_content1"] =host_base64;
		}else{
			alert("自定义host区内容有误，提交自定义host必须以hosts:开头");
			return false;
		} 
	}else{
		db_merlinclash["merlinclash_host_content1"] = "";
	}
	var radio = document.getElementsByName("dnsplan").innerHTML = getradioval();
	db_merlinclash["merlinclash_enable"] = E("merlinclash_enable").checked ? '1' : '0';
	db_merlinclash["merlinclash_watchdog"] = E("merlinclash_watchdog").checked ? '1' : '0';
	db_merlinclash["merlinclash_kcpswitch"] = E("merlinclash_kcpswitch").checked ? '1' : '0';
	db_merlinclash["merlinclash_ipv6switch"] = E("merlinclash_ipv6switch").checked ? '1' : '0';
	//db_merlinclash["merlinclash_dlercloud_check"] = E("merlinclash_dlercloud_check").checked ? '1' : '0';
	db_merlinclash["merlinclash_dashboardswitch"] = E("merlinclash_dashboardswitch").checked ? '1' : '0';
	if(E("merlinclash_dashboardswitch").checked){
		if(!$.trim($('#merlinclash_dashboard_secret').val())){
			alert("公网访问面板开启，密码不能为空！");
			return false;
		}
	}
	db_merlinclash["merlinclash_dashboard_secret"] = E("merlinclash_dashboard_secret").value;

	//db_merlinclash["merlinclash_nmswitch"] = E("merlinclash_nmswitch").checked ? '1' : '0';
	db_merlinclash["merlinclash_unblockmusic_enable"] = E("merlinclash_unblockmusic_enable").checked ? '1' : '0';
	db_merlinclash["merlinclash_unblockmusic_endpoint"] = E("merlinclash_unblockmusic_endpoint").value;
	db_merlinclash["merlinclash_unblockmusic_musicapptype"] = E("merlinclash_unblockmusic_musicapptype").value;
	if(db_merlinclash["merlinclash_UnblockNeteaseMusic_version"] >= "0.2.5"){
		if(!$.trim($('#merlinclash_unblockmusic_platforms_numbers').val())){
			alert("搜索结果值不能为空！");
			return false;
		}
		db_merlinclash["merlinclash_unblockmusic_platforms_numbers"] = E("merlinclash_unblockmusic_platforms_numbers").value;
	}//db_merlinclash["merlinclash_kpswitch"] = E("merlinclash_kpswitch").checked ? '1' : '0';
	db_merlinclash["merlinclash_dnsplan"] = radio;
	db_merlinclash["merlinclash_links"] = E("merlinclash_links").value;

	var links2 = encodeURIComponent(E("merlinclash_links2").value);
	db_merlinclash["merlinclash_links2"] = links2;
	//URL编码后再传入后端
	var links3 = encodeURIComponent(E("merlinclash_links3").value);
	db_merlinclash["merlinclash_links3"] = links3;
	db_merlinclash["merlinclash_udpr"] = E("merlinclash_udpr").checked ? '1' : '0';
	db_merlinclash["merlinclash_unblockmusic_bestquality"] = E("merlinclash_unblockmusic_bestquality").checked ? '1' : '0';
	//20200828+
	db_merlinclash["merlinclash_check_delay_cbox"] = E("merlinclash_check_delay_cbox").checked ? '1' : '0';
	db_merlinclash["merlinclash_urltestTolerance_cbox"] = E("merlinclash_urltestTolerance_cbox").checked ? '1' : '0';
	if(E("merlinclash_check_delay_cbox").checked){
		if(!$.trim($('#merlinclash_check_delay_time').val())){
			alert("自定义延迟检查开启，秒数不能为空！");
			return false;
		}
	}
	db_merlinclash["merlinclash_check_delay_time"] = E("merlinclash_check_delay_time").value;
	db_merlinclash["merlinclash_watchdog_delay_time"] = E("merlinclash_watchdog_delay_time").value;
	//20200828-
	db_merlinclash["merlinclash_yamlsel"] = E("merlinclash_yamlsel").value;
	yamlsel_tmp1 = E("merlinclash_yamlsel").value;
	db_merlinclash["merlinclash_delyamlsel"] = E("merlinclash_delyamlsel").value;
	//20200630+++
	db_merlinclash["merlinclash_acl4ssrsel"] = E("merlinclash_acl4ssrsel").value;
	//20200630---	
	db_merlinclash["merlinclash_clashtarget"] = E("merlinclash_clashtarget").value;
	db_merlinclash["merlinclash_urltestTolerancesel"] = E("merlinclash_urltestTolerancesel").value;
	//自定规则
	//if(E("ACL_table")){
	//	var tr = E("ACL_table").getElementsByTagName("tr");
	//	//for (var i = 1; i < tr.length - 1; i++) {
	//	for (var i = 1; i < tr.length ; i++) {	
	//		var rowid = tr[i].getAttribute("id").split("_")[2];
	//		if (E("merlinclash_acl_type_" + i)){
	//			db_merlinclash["merlinclash_acl_type_" + rowid] = E("merlinclash_acl_type_" + rowid).value;
	//			db_merlinclash["merlinclash_acl_content_" + rowid] = E("merlinclash_acl_content_" + rowid).value;
	//			db_merlinclash["merlinclash_acl_lianjie_" + rowid] = E("merlinclash_acl_lianjie_" + rowid).value;					
	//		}else{
	//			
	//		}				
	//	}
	//}else{
	//	
	//}
	
	//KCP
	if(E("KCP_table")){
		var tr = E("KCP_table").getElementsByTagName("tr");
		//for (var i = 1; i < tr.length - 1; i++) {
		for (var i = 1; i < tr.length ; i++) {	
			var rowid = tr[i].getAttribute("id").split("_")[2];
			if (E("merlinclash_kcp_lport_" + i)){
				db_merlinclash["merlinclash_kcp_lport_" + rowid] = E("merlinclash_kcp_lport_" + rowid).value;
				db_merlinclash["merlinclash_kcp_server_" + rowid] = E("merlinclash_kcp_server_" + rowid).value;
				db_merlinclash["merlinclash_kcp_port_" + rowid] = E("merlinclash_kcp_port_" + rowid).value;
				db_merlinclash["merlinclash_kcp_param_" + rowid] = E("merlinclash_kcp_param_" + rowid).value;
			}else{
				
			}				
		}
	}else{

	}
	var act;
	if(E("merlinclash_enable").checked){ 
			//act = "start";
			db_merlinclash["merlinclash_action"] = "1";
			//alert('bbb');
	}else{
			//act = "stop";
			db_merlinclash["merlinclash_action"] = "0";
			//alert('ccc');
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_status.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			var arr = response.result.split("@");			
			if (arr[0] == "" || arr[1] == "") {
				
			} else {
				yamlsel_tmp2 = arr[7];
				//更换配置文件，清空节点指定内容
				if(yamlsel_tmp2==null){
					yamlsel_tmp2=yamlsel_tmp1
					
				}
				if(yamlsel_tmp2!=yamlsel_tmp1){
					//apply_delallpgnodes();
					db_merlinclash["merlinclash_action"] = "1";
					db_merlinclash["merlinclash_yamlselchange"] = "1";
				}
				if(yamlsel_tmp2 == yamlsel_tmp1){
					//apply_delallpgnodes();
					db_merlinclash["merlinclash_action"] = "1";
					db_merlinclash["merlinclash_yamlselchange"] = "0";
				}
				push_data("clash_config.sh", "start",  db_merlinclash);
			}
		}
	});

	
}
function push_data(script, arg, obj, flag){
	if (!flag) showMCLoadingBar();
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": script, "params":[arg], "fields": obj};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			//alert(flag);
			if(response.result == id){
				if(flag && flag == "1"){
					refreshpage();
				}else if(flag && flag == "2"){
					//continue;
					//do nothing
				}else{
					//alert('get');
					get_realtime_log();
				}
			}
		}
	});
}
function tabSelect(w) {
	for (var i = 0; i <= 10; i++) {
		$('.show-btn' + i).removeClass('active');
		$('#tablet_' + i).hide();
	}
	$('.show-btn' + w).addClass('active');
	$('#tablet_' + w).show();
}
function dingyue() {
	tabSelect(1);
	$('#apply_button').hide(); 	
	$('#delallpgnodes_button').hide();
	$('#delallowneracls_button').hide();
}
function dnsplan() {
	if(db_merlinclash["merlinclash_updata_date"]){
		E("geoip_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_updata_date"]+"</span>";
	}		
	tabSelect(4);
	$('#apply_button').hide(); 
	$('#delallpgnodes_button').hide();	
	$('#delallowneracls_button').hide();	
}
function toggle_func() {
	//$("#merlinclash_enable").click(
	//function() {
	//	""
	//});
	$(".show-btn0").click(
		function() {
			tabSelect(0);			
			$('#apply_button').show();
			$('#delallpgnodes_button').hide(); 	
			$('#delallowneracls_button').hide();		
		});
	$(".show-btn1").click( 
		function() {
			tabSelect(1);
			$('#apply_button').hide(); 
			$('#delallpgnodes_button').hide();
			$('#delallowneracls_button').hide();
			
		});
	$(".show-btn2").click(
		function() {
			tabSelect(2);
			$('#apply_button').show();
			$('#delallpgnodes_button').hide();
			$('#delallowneracls_button').show();
			//refresh_acl_table();
		});
	$(".show-btn9").click(
		function() {
			tabSelect(9);
			$('#apply_button').show();
			$('#delallpgnodes_button').hide();
			$('#delallowneracls_button').hide();
			//refresh_device_table();
			//refresh_acl_table();
		});
	//高级模式
	$(".show-btn3").click(
		function() {
			tabSelect(3);
			$('#apply_button').show(); 
			$('#delallpgnodes_button').hide();
			$('#delallowneracls_button').hide();
			
		});
	$(".show-btn4").click(
		function() {
			if(db_merlinclash["merlinclash_updata_date"]){
				E("geoip_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_updata_date"]+"</span>";
			}
			tabSelect(4);
			$('#apply_button').hide(); 
			$('#delallpgnodes_button').hide();	
			$('#delallowneracls_button').hide();					
		});
	$(".show-btn5").click(
		function() {
			//get_log();
			tabSelect(5);
			$('#apply_button').hide();
			$('#delallpgnodes_button').hide();
			$('#delallowneracls_button').hide();
			
			
		});
	$(".show-btn6").click(
		function() {
			tabSelect(6);
			$('#apply_button').hide();
			$('#delallpgnodes_button').hide();
			$('#delallowneracls_button').hide();
			
			
		});
	$(".show-btn7").click(
		function() {
			tabSelect(7);
			$('#apply_button').hide();
			$('#delallpgnodes_button').hide();	
			$('#delallowneracls_button').hide();	
					
		});
        $(".show-btn8").click(
		function() {
			if(db_merlinclash["merlinclash_UnblockNeteaseMusic_version"] >= "0.2.5"){
				document.getElementById("merlinclash_unblockmusic_platforms_numbers").style.visibility="visible"	
			}else{
				document.getElementById("merlinclash_unblockmusic_platforms_numbers").style.visibility="hidden"	
			}
			tabSelect(8);
			$('#apply_button').show();
			$('#delallpgnodes_button').hide(); 
			$('#delallowneracls_button').hide();
								
		});
        $(".show-btn10").click(
		function() {
			
			tabSelect(10);
			$('#apply_button').hide();
			$('#delallpgnodes_button').hide();
			$('#delallowneracls_button').hide();
		});
	//显示默认页
	$(".show-btn0").trigger("click");

}

function get_clash_status_front() {
	if (db_merlinclash['merlinclash_enable'] != "1") {
		E("clash_state2").innerHTML = "clash进程 - " + "Waiting...";
		E("clash_state3").innerHTML = "看门狗进程 - " + "Waiting...";
		E("dashboard_state2").innerHTML = "管理面板";
		//E("dashboard_state3").innerHTML = "面板端口";
		E("dashboard_state4").innerHTML = "面板密码";
		return false;
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_status.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			var arr = response.result.split("@");
			
			if (arr[0] == "" || arr[1] == "") {
				E("clash_state2").innerHTML = "clash进程 - " + "Waiting for first refresh...";
				E("clash_state3").innerHTML = "看门狗进程 - " + "Waiting for first refresh...";
				E("dashboard_state2").innerHTML = "管理面板";
				//E("dashboard_state3").innerHTML = "面板端口";
				E("dashboard_state4").innerHTML = "面板密码";
			} else {
				E("clash_state2").innerHTML = arr[0];
				E("clash_state3").innerHTML = arr[1];
				$("#yacd").html("<a type='button' href='http://"+ location.hostname + ":" +arr[3]+ "/ui/yacd/index.html?hostname=" + location.hostname + "&port=" + arr[3] + "&secret=" + arr[16] +"'" + " target='_blank' >访问 YACD-Clash 面板</a>");
				$("#razord").html("<a type='button' href='http://"+ location.hostname + ":" +arr[3]+ "/ui/razord/index.html' target='_blank' >访问 RAZORD-Clash 面板</a>");		
				//$("#yacd").html("<a type='button' href='http://"+ arr[5] + "/ui/yacd/index.html?secret=" + arr[15] + "'" + " target='_blank' >访问 YACD-Clash 面板</a>");
				//$("#razord").html("<a type='button' href='http://"+ arr[5] + "/ui/razord/index.html' target='_blank' >访问 RAZORD-Clash 面板</a>");				
				E("dashboard_state2").innerHTML = arr[5];
				//E("dashboard_state3").innerHTML = arr[6];
				E("dashboard_state4").innerHTML = arr[15];
				yamlsel_tmp2 = arr[7];
				E("merlinclash_unblockmusic_version").innerHTML = arr[8];
				E("merlinclash_unblockmusic_status").innerHTML = arr[9];
				//E("proxygroup_version").innerHTML = arr[10];
				//E("proxygame_version").innerHTML = arr[11];
				E("patch_version").innerHTML = arr[12];
				E("sc_version").innerHTML = arr[13];
				E("clash_yamlsel").innerHTML = arr[14];
			}
		}
	});
	setTimeout("get_clash_status_front();", 60000);
}
//----------------详细状态-----------------------------
function close_proc_status() {
	$("#detail_status").fadeOut(200);
}
function get_proc_status() {
	$("#detail_status").fadeIn(500);
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_proc_status.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				write_proc_status();
			}
		}
	});
}
function write_proc_status() {
	$.ajax({
		url: '/_temp/clash_proc_status.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(res) {
			$('#proc_status').val(res);
		}
	});
}
//----------------详细状态-----------------------------

function dc_ss_yaml (action) {
	var dbus_post = {};
	var dcss = document.getElementById("dc_ss_1").innerHTML;
	dbus_post["merlinclash_links"] = dcss;
	
	dbus_post["merlinclash_uploadrename"] = "dler_ss";
	dbus_post["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", action,  dbus_post);
		
}
function dc_v2_yaml (action) {
	var dbus_post = {};
	var dcv2 = document.getElementById("dc_v2_1").innerHTML;
	dbus_post["merlinclash_links"] = dcv2;
	
	dbus_post["merlinclash_uploadrename"] = "dler_v2";
	dbus_post["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", action,  dbus_post);
		
}
function dc_tj_yaml (action) {
	var dbus_post = {};
	var dctj = document.getElementById("dc_trojan_1").innerHTML;
	dbus_post["merlinclash_links"] = dctj;
	
	dbus_post["merlinclash_uploadrename"] = "dler_tj";
	dbus_post["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", action,  dbus_post);
		
}
function get_online_yaml(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_links').val())){
		alert("订阅链接不能为空！");
		return false;
	}
	dbus_post["merlinclash_links"] = db_merlinclash["merlinclash_links"] = (E("merlinclash_links").value);
	dbus_post["merlinclash_uploadrename"] = db_merlinclash["merlinclash_uploadrename"] = (E("merlinclash_uploadrename").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_online_yaml.sh", action,  dbus_post);
	
}
function get_online_yaml2(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_links2').val())){
		alert("订阅链接不能为空！");
		return false;
	}
	var links2 = encodeURIComponent(E("merlinclash_links2").value);
	dbus_post["merlinclash_links2"] = db_merlinclash["merlinclash_links2"] = links2;
	dbus_post["merlinclash_uploadrename2"] = db_merlinclash["merlinclash_uploadrename2"] = (E("merlinclash_uploadrename2").value);
	//dbus_post["merlinclash_localrulesel"] = db_merlinclash["merlinclash_localrulesel"] = (E("merlinclash_localrulesel").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_online_yaml_2.sh", action,  dbus_post);
	
}
function get_online_yaml3(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_links3').val())){
		alert("订阅链接不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_subconverter_include').val())){
		var include = "";
	}else{
		var include = encodeURIComponent(E("merlinclash_subconverter_include").value);
	}
	if(!$.trim($('#merlinclash_subconverter_exclude').val())){
		var exclude = "";
	}else{
		var exclude = encodeURIComponent(E("merlinclash_subconverter_exclude").value);
	}
	var links3 = encodeURIComponent(E("merlinclash_links3").value);
	//alert(links3);
	dbus_post["merlinclash_links3"] = db_merlinclash["merlinclash_links3"] = links3;
	dbus_post["merlinclash_uploadrename4"] = db_merlinclash["merlinclash_uploadrename4"] = (E("merlinclash_uploadrename4").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	//20200630+++
	dbus_post["merlinclash_acl4ssrsel"] = db_merlinclash["merlinclash_acl4ssrsel"] = E("merlinclash_acl4ssrsel").value;
	//20200630---
	//20200804
	dbus_post["merlinclash_clashtarget"] = db_merlinclash["merlinclash_clashtarget"] = E("merlinclash_clashtarget").value;
	dbus_post["merlinclash_subconverter_include"] = db_merlinclash["merlinclash_subconverter_include"] = include;
	dbus_post["merlinclash_subconverter_exclude"] = db_merlinclash["merlinclash_subconverter_exclude"] = exclude;
	dbus_post["merlinclash_subconverter_emoji"] = db_merlinclash["merlinclash_subconverter_emoji"] = E("merlinclash_subconverter_emoji").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_udp"] = db_merlinclash["merlinclash_subconverter_udp"] = E("merlinclash_subconverter_udp").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_append_type"] = db_merlinclash["merlinclash_subconverter_append_type"] = E("merlinclash_subconverter_append_type").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_sort"] = db_merlinclash["merlinclash_subconverter_sort"] = E("merlinclash_subconverter_sort").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_fdn"] = db_merlinclash["merlinclash_subconverter_fdn"] = E("merlinclash_subconverter_fdn").checked ? '1' : '0';
	//merlinclash_subconverter_scv
	dbus_post["merlinclash_subconverter_scv"] = db_merlinclash["merlinclash_subconverter_scv"] = E("merlinclash_subconverter_scv").checked ? '1' : '0';
	dbus_post["merlinclash_subconverter_tfo"] = db_merlinclash["merlinclash_subconverter_tfo"] = E("merlinclash_subconverter_tfo").checked ? '1' : '0';
	push_data("clash_online_yaml4.sh", action,  dbus_post);
	
}
function get_online_yaml4(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_dc_subconverter_include').val())){
		var include = "";
	}else{
		var include = encodeURIComponent(E("merlinclash_dc_subconverter_include").value);
	}
	if(!$.trim($('#merlinclash_dc_subconverter_exclude').val())){
		var exclude = "";
	}else{
		var exclude = encodeURIComponent(E("merlinclash_dc_subconverter_exclude").value);
	}
	var dcss = document.getElementById("dc_ss_1").innerHTML;
	var dcv2 = document.getElementById("dc_v2_1").innerHTML;
	var dctj = document.getElementById("dc_trojan_1").innerHTML;
	if(dcss == "null"){
		dcss = ""
	}
	if(dcv2 == "null"){
		dcv2 = ""
	}
	if(dctj == "null"){
		dctj = ""
	}
	var links3 = dcss + "|" + dcv2 + "|" + dctj;
	links3 = encodeURIComponent(links3);
	//alert(links3);
	dbus_post["merlinclash_dc_links3"] = links3;
	dbus_post["merlinclash_dc_uploadrename4"] = "dler_3in1";
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	//20200630+++
	dbus_post["merlinclash_dc_acl4ssrsel"] = db_merlinclash["merlinclash_dc_acl4ssrsel"] = E("merlinclash_dc_acl4ssrsel").value;
	//20200630---
	//20200804
	dbus_post["merlinclash_dc_clashtarget"] = db_merlinclash["merlinclash_dc_clashtarget"] = E("merlinclash_dc_clashtarget").value;
	dbus_post["merlinclash_dc_subconverter_include"] = db_merlinclash["merlinclash_dc_subconverter_include"] = include;
	dbus_post["merlinclash_dc_subconverter_exclude"] = db_merlinclash["merlinclash_dc_subconverter_exclude"] = exclude;
	dbus_post["merlinclash_dc_subconverter_emoji"] = db_merlinclash["merlinclash_dc_subconverter_emoji"] = E("merlinclash_dc_subconverter_emoji").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_udp"] = db_merlinclash["merlinclash_dc_subconverter_udp"] = E("merlinclash_dc_subconverter_udp").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_append_type"] = db_merlinclash["merlinclash_dc_subconverter_append_type"] = E("merlinclash_dc_subconverter_append_type").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_sort"] = db_merlinclash["merlinclash_dc_subconverter_sort"] = E("merlinclash_dc_subconverter_sort").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_fdn"] = db_merlinclash["merlinclash_dc_subconverter_fdn"] = E("merlinclash_dc_subconverter_fdn").checked ? '1' : '0';
	//merlinclash_subconverter_scv
	dbus_post["merlinclash_dc_subconverter_scv"] = db_merlinclash["merlinclash_dc_subconverter_scv"] = E("merlinclash_dc_subconverter_scv").checked ? '1' : '0';
	dbus_post["merlinclash_dc_subconverter_tfo"] = db_merlinclash["merlinclash_dc_subconverter_tfo"] = E("merlinclash_dc_subconverter_tfo").checked ? '1' : '0';
	push_data("clash_online_yaml4.sh", action,  dbus_post);
	
	
}
//导出自定义规则以及还原
function down_clashrestorerule(arg) {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downrule.sh", "params":[arg], "fields": "" };
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			if(response.result == id){
				if(arg == 1){
					var downloadA = document.createElement('a');
					var josnData = {};
					var a = "http://"+window.location.hostname+"/_temp/"+"clash_rulebackup.sh"
					var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
					downloadA.href = a;
					downloadA.download = "clash_rulebackup.sh";
					downloadA.click();
					window.URL.revokeObjectURL(downloadA.href);
				}
			}
		}
	});	
}
function upload_clashrestorerule() {
	var filename = $("#clashrestorerule").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length - 1];
	if (filelast != "sh" ) {
		alert('备份文件格式不正确！');
		return false;
	}
	E('clashrestorerule_info').style.display = "none";
	var formData = new FormData();
	formData.append("clash_rulebackup.sh", $('#clashrestorerule')[0].files[0]);
	$.ajax({
		url: '/_upload',
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				E('clashrestorerule_info').style.display = "block";
				restore_clash_rule();
			}
		}
	});	
}
function restore_clash_rule() {
	showMCLoadingBar();
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action = 23;
	push_data("clash_downrule.sh", action,  dbus_post);
}
//------------------------------------------------------------------------------------------
//导出绕行设置以及还原
function down_passdevice(arg) {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downpassdevice.sh", "params":[arg], "fields": "" };
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		cache:false,
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response){
			if(response.result == id){
				if(arg == 1){
					var downloadA = document.createElement('a');
					var josnData = {};
					var a = "http://"+window.location.hostname+"/_temp/"+"clash_passdevicebackup.sh"
					var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
					downloadA.href = a;
					downloadA.download = "clash_passdevicebackup.sh";
					downloadA.click();
					window.URL.revokeObjectURL(downloadA.href);
				}
			}
		}
	});	
}
function upload_passdevice() {
	var filename = $("#passdevice").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length - 1];
	if (filelast != "sh" ) {
		alert('备份文件格式不正确！');
		return false;
	}
	E('passdevice_info').style.display = "none";
	var formData = new FormData();
	formData.append("clash_passdevicebackup.sh", $('#passdevice')[0].files[0]);
	$.ajax({
		url: '/_upload',
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				E('passdevice_info').style.display = "block";
				restore_passdevice();
			}
		}
	});	
}
function restore_passdevice() {
	showMCLoadingBar();
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action = 24;
	push_data("clash_downpassdevice.sh", action,  dbus_post);
}
//
function ssconvert(action) {
	var dbus_post = {};
	dbus_post["merlinclash_uploadrename3"] = db_merlinclash["merlinclash_uploadrename3"] = (E("merlinclash_uploadrename3").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_online_yaml3.sh", action,  dbus_post);
}
function del_yaml_sel(action) {
	var dbus_post = {};
	if(!$.trim($('#merlinclash_delyamlsel').val())){
		alert("配置文件不能为空！");
		return false;
	}
	if(E("merlinclash_delyamlsel").value == db_merlinclash["merlinclash_yamlsel"]){
		alert("选择的配置文件为当前使用文件，不予删除！");
		return false;
	}
	dbus_post["merlinclash_delyamlsel"] = db_merlinclash["merlinclash_delyamlsel"] = (E("merlinclash_delyamlsel").value);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "4"
	push_data("clash_delyamlsel.sh", action, dbus_post);
	//yaml_select();
}
function download_yaml_sel() {
	//下载前清空/tmp/upload文件夹下的yaml格式文件	
	if(!$.trim($('#merlinclash_delyamlsel').val())){
		alert("配置文件不能为空！");
		return false;
	}
	var dbus_post = {};
	clear_yaml();
	dbus_post["merlinclash_delyamlsel"] = db_merlinclash["merlinclash_delyamlsel"] = (E("merlinclash_delyamlsel").value);
	//alert(dbus_post["merlinclash_delyamlsel"]);
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downyamlsel.sh", "params":[], "fields": dbus_post};
	var yamlname=""
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			yamlname = response.result;
			//alert(yamlname);
			download(yamlname);
		}
	});
}
function download(yamlname) {
	var downloadA = document.createElement('a');
	var josnData = {};
	var a = "http://"+window.location.hostname+"/_temp/"+yamlname
	var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
	downloadA.href = a;
	downloadA.download = yamlname;
	downloadA.click();
	window.URL.revokeObjectURL(downloadA.href);
}
//20200904下载HOST
function download_host() {
	var dbus_post = {};	
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_downhost.sh", "params":[], "fields": dbus_post};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			hostfile = response.result;
			//alert(yamlname);
			downloadhostfile(hostfile);
		}
	});
}
function downloadhostfile() {
	var downloadA = document.createElement('a');
	var josnData = {};
	var a = "http://"+window.location.hostname+"/_temp/"+hostfile
	var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
	downloadA.href = a;
	downloadA.download = hostfile;
	downloadA.click();
	window.URL.revokeObjectURL(downloadA.href);
}
//20200904
function yaml_view() {
$.ajax({
		url: '/_temp/view.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("yaml_content1");
			if (response.search("BBABBBBC") != -1) {
				//alert("1");
				retArea.value = response.replace("BBABBBBC", " ");
				var pageH = parseInt(E("FormTitle").style.height.split("px")[0]); 
				//alert(pageH);
				if(pageH){
					autoTextarea(E("yaml_content1"), 0, (pageH - 308));
					
				}else{
					autoTextarea(E("yaml_content1"), 0, 980);
					
				}
				return true;
			}
			//if (_responseLen == response.length) {
			//	noChange++;
			//} else {
			//	noChange = 0;
			//}
			//if (noChange > 5) {
			//	return false;
			//} else {
			//	setTimeout("yaml_view();", 300);
			//}
			retArea.value = response;
			//alert(retArea.value);
			_responseLen = response.length;
		},
		error: function(xhr) {
			E("yaml_content1").value = "获取配置文件信息失败！";
		}
	});
}
//检查版本更新
function update_mc() {
	var dbus_post = {};
	db_merlinclash["merlinclash_action"] = "20";
	push_data("clash_update_version.sh", "update",  dbus_post);
}

function node_remark_view() {
	var txt = E("merlinclash_yamlsel").value;
	//alert(txt);
$.ajax({		
		//url: '/_temp/mark_status.txt',
		url: '/_temp/'+txt+'_status.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("nodes_content1");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				var pageH = parseInt(E("FormTitle").style.height.split("px")[0]); 
				if(pageH){
					autoTextarea(E("nodes_content1"), 0, (pageH - 308));
				}else{
					autoTextarea(E("nodes_content1"), 0, 980);
				}
				return true;
			}
			//if (_responseLen == response.length) {
			//	noChange++;
			//} else {
			//	noChange = 0;
			//}
			//if (noChange > 5) {
			//	return false;
			//} else {
				//setTimeout("node_remark_view();", 300);
			//}
			retArea.value = response;
			_responseLen = response.length;
		},
		error: function(xhr) {
			E("nodes_content1").value = "获取节点还原信息失败！";
		}
	});
}
function get_log() {
	$.ajax({
		url: '/_temp/merlinclash_log.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			var retArea = E("log_content1");
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				var pageH = parseInt(E("FormTitle").style.height.split("px")[0]); 
				if(pageH){
					autoTextarea(E("log_content1"), 0, (pageH - 308));
				}else{
					autoTextarea(E("log_content1"), 0, 980);
				}
				return true;
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 5) {
				return false;
			} else {
				setTimeout("get_log();", 300);
			}
			retArea.value = response;
			_responseLen = response.length;
		},
		error: function(xhr) {
			E("log_content1").value = "获取日志失败！";
		}
	});
}
function count_down_close1() {
	if (x == "0") {
		hideMCLoadingBar();
	}
	if (x < 0) {
		E("ok_button1").value = "手动关闭"
		return false;
	}
	E("ok_button1").value = "自动关闭（" + x + "）"
		--x;
	setTimeout("count_down_close1();", 1000);
}
function get_realtime_log() {
	$.ajax({
		url: '/_temp/merlinclash_log.txt',
		type: 'GET',
		async: true,
		cache: false,
		dataType: 'text',
		success: function(response) {
			var retArea = E("log_content3");
			//alert(response.search("BBABBBBC"));
			//console.log(retArea);
			if (response.search("BBABBBBC") != -1) {
				retArea.value = response.replace("BBABBBBC", " ");
				E("ok_button").style.display = "";
				retArea.scrollTop = retArea.scrollHeight;
				count_down_close1();
				return true;
			}
			if (_responseLen == response.length) {
				noChange++;
			} else {
				noChange = 0;
			}
			if (noChange > 1000) {
				return false;
			} else {
				setTimeout("get_realtime_log();", 100);
			}
			retArea.value = response.replace("BBABBBBC", " ");
			retArea.scrollTop = retArea.scrollHeight;
			_responseLen = response.length;
		},
		error: function() {
			setTimeout("get_realtime_log();", 500);
		}
	});
}
//获取host.yaml
function host_yaml_view() {
$.ajax({
		url: '/_temp/host_yaml.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			//alert(response);
			var retArea = E("merlinclash_host_content1");
			retArea.value = response;
			
		},
		error: function(xhr) {
			E("merlinclash_host_content1").value = "获取host文件失败！";
		}
	});
}
//
function getradioval() {
	var radio = document.getElementsByName("dnsplan");
	for(i = 0; i< radio.length; i++){
		if(radio[i].checked){
			return radio[i].value
		}
	}
	var yamlsel = document.getElementsByName("yamlsel");
	for(i = 0; i< yamlsel.length; i++){
		if(yamlsel[i].checked){
			return yamlsel[i].value
		}
	}
}
function reload_Soft_Center() {
	location.href = "/Module_Softcenter.asp";
}
function load_cron_params() {

	for (var i = 0; i < 24; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp0 = _i;
		_tmp = _i + "时";
		//_tmp[1] = _i + "时";
		//option_rebh.push(_tmp);
		$("#merlinclash_select_hour").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_regular_hour").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_clash_restart_hour").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
	}

	for (var i = 0; i < 61; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp0 = _i;
		_tmp = _i + "分";
		//_tmp[1] = _i + "分";
		//option_rebm.push(_tmp);
		$("#merlinclash_select_minute").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_regular_minute").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_clash_restart_minute").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
	}
	var option_rebw = [["1", "一"], ["2", "二"], ["3", "三"], ["4", "四"], ["5", "五"], ["6", "六"], ["7", "日"]];
	for (var i = 0; i < option_rebw.length; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp = option_rebw[_i];
		_tmp1 = _tmp[1];
		_tmp0 = _tmp[0];
		//_tmp[1] = _i + "分";
		//option_rebm.push(_tmp);
		$("#merlinclash_select_week").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
		$("#merlinclash_select_regular_week").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
		$("#merlinclash_select_clash_restart_week").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
	}
	var option_trit = [["2", "2分钟"], ["5", "5分钟"], ["10", "10分钟"], ["15", "15分钟"], ["20", "20分钟"], ["25", "25分钟"], ["30", "30分钟"], ["1", "1小时"], ["3", "3小时"], ["6", "6小时"], ["12", "12小时"]];
	for (var i = 0; i < option_trit.length; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp = option_trit[_i];
		_tmp1 = _tmp[1];
		_tmp0 = _tmp[0];
		//_tmp[1] = _i + "分";
		//option_rebm.push(_tmp);
		$("#merlinclash_select_regular_minute_2").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
		$("#merlinclash_select_clash_restart_minute_2").append("<option value='"+_tmp0+"' >"+_tmp1+"</option>");
	}
	for (var i = 1; i < 32; i++){
		var _tmp = [];
		var _tmp0 = [];
		_i = String(i)
		_tmp0 = _i;
		_tmp = _i + "日";
		$("#merlinclash_select_day").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_regular_day").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
		$("#merlinclash_select_clash_restart_day").append("<option value='"+_tmp0+"' >"+_tmp+"</option>");
	}
}
function show_job() {
	
	var option_rebw = [["1", "一"], ["2", "二"], ["3", "三"], ["4", "四"], ["5", "五"], ["6", "六"], ["7", "日"]];

	//$("#merlinclash_yamlsel").append("<option value='"+a+"' >"+a+"</option>");
	if (E("merlinclash_select_job").value == "1" ){
		$('#merlinclash_select_hour').hide();
		$('#merlinclash_select_minute').hide();
		$('#merlinclash_select_day').hide(); 
		$('#merlinclash_select_week').hide(); 

	}
	else if (E("merlinclash_select_job").value == "2" ){
		$('#merlinclash_select_hour').show();
		$('#merlinclash_select_minute').show();
		$('#merlinclash_select_week').hide(); 
		$('#merlinclash_select_day').hide(); 
	}
	else if (E("merlinclash_select_job").value == "3" ){
		$('#merlinclash_select_hour').show();
		$('#merlinclash_select_minute').show();
		$('#merlinclash_select_day').hide(); 
		$('#merlinclash_select_week').show(); 
	}
	else if (E("merlinclash_select_job").value == "4" ){
		$('#merlinclash_select_day').show(); 
		$('#merlinclash_select_hour').show();
		$('#merlinclash_select_minute').show();
		$('#merlinclash_select_week').hide(); 
	}
	if (E("merlinclash_select_regular_subscribe").value == "1" ){
		$('#merlinclash_select_regular_hour').hide();
		$('#merlinclash_select_regular_minute').hide();
		$('#merlinclash_select_regular_day').hide(); 
		$('#merlinclash_select_regular_week').hide(); 
		$('#merlinclash_select_regular_minute_2').hide(); 
	}
	else if (E("merlinclash_select_regular_subscribe").value == "2" ){
		$('#merlinclash_select_regular_hour').show();
		$('#merlinclash_select_regular_minute').show();
		$('#merlinclash_select_regular_week').hide(); 
		$('#merlinclash_select_regular_day').hide(); 
		$('#merlinclash_select_regular_minute_2').hide(); 
	}
	else if (E("merlinclash_select_regular_subscribe").value == "3" ){
		$('#merlinclash_select_regular_hour').show();
		$('#merlinclash_select_regular_minute').show();
		$('#merlinclash_select_regular_day').hide(); 
		$('#merlinclash_select_regular_week').show(); 
		$('#merlinclash_select_regular_minute_2').hide(); 
	}
	else if (E("merlinclash_select_regular_subscribe").value == "4" ){
		$('#merlinclash_select_regular_day').show(); 
		$('#merlinclash_select_regular_hour').show();
		$('#merlinclash_select_regular_minute').show();
		$('#merlinclash_select_regular_week').hide(); 
		$('#merlinclash_select_regular_minute_2').hide(); 
	} 
	else if (E("merlinclash_select_regular_subscribe").value == "5" ){
		$('#merlinclash_select_regular_day').hide(); 
		$('#merlinclash_select_regular_hour').hide();
		$('#merlinclash_select_regular_minute').hide();
		$('#merlinclash_select_regular_week').hide(); 
		$('#merlinclash_select_regular_minute_2').show(); 
	} 
	if (E("merlinclash_select_clash_restart").value == "1" ){
		$('#merlinclash_select_clash_restart_hour').hide();
		$('#merlinclash_select_clash_restart_minute').hide();
		$('#merlinclash_select_clash_restart_day').hide(); 
		$('#merlinclash_select_clash_restart_week').hide(); 
		$('#merlinclash_select_clash_restart_minute_2').hide(); 
	}
	else if (E("merlinclash_select_clash_restart").value == "2" ){
		$('#merlinclash_select_clash_restart_hour').show();
		$('#merlinclash_select_clash_restart_minute').show();
		$('#merlinclash_select_clash_restart_week').hide(); 
		$('#merlinclash_select_clash_restart_day').hide(); 
		$('#merlinclash_select_clash_restart_minute_2').hide(); 
	}
	else if (E("merlinclash_select_clash_restart").value == "3" ){
		$('#merlinclash_select_clash_restart_hour').show();
		$('#merlinclash_select_clash_restart_minute').show();
		$('#merlinclash_select_clash_restart_day').hide(); 
		$('#merlinclash_select_clash_restart_week').show(); 
		$('#merlinclash_select_clash_restart_minute_2').hide(); 
	}
	else if (E("merlinclash_select_clash_restart").value == "4" ){
		$('#merlinclash_select_clash_restart_day').show(); 
		$('#merlinclash_select_clash_restart_hour').show();
		$('#merlinclash_select_clash_restart_minute').show();
		$('#merlinclash_select_clash_restart_week').hide(); 
		$('#merlinclash_select_clash_restart_minute_2').hide(); 
	} 
	else if (E("merlinclash_select_clash_restart").value == "5" ){
		$('#merlinclash_select_clash_restart_day').hide(); 
		$('#merlinclash_select_clash_restart_hour').hide();
		$('#merlinclash_select_clash_restart_minute').hide();
		$('#merlinclash_select_clash_restart_week').hide(); 
		$('#merlinclash_select_clash_restart_minute_2').show(); 
	} 
}
function dc_login() {
    var dbus_post = {};
    dbus_post["merlinclash_dc_name"] = db_merlinclash["merlinclash_dc_name"] = E("merlinclash_dc_name").value;
    dbus_post["merlinclash_dc_passwd"] = db_merlinclash["merlinclash_dc_passwd"] = E("merlinclash_dc_passwd").value;
	var arg="login"
    var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dclogin.sh", "params":[arg], "fields": dbus_post};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			var arr = response.result;	
            //alert(arr);	
            if (arr != "200"){
                alert("登陆用户名/密码有误。");
                return false;
            } else{
                dc_info();
            }			
		}
	});
}

function dc_logout() {
    var dbus_post = {};
    dbus_post["merlinclash_dc_name"] = db_merlinclash["merlinclash_dc_name"] = E("merlinclash_dc_name").value;
    dbus_post["merlinclash_dc_passwd"] = db_merlinclash["merlinclash_dc_passwd"] = E("merlinclash_dc_passwd").value;
	var arg="logout"
    var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dclogin.sh", "params":[arg], "fields": dbus_post};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			//var arr = response.result;	
            //alert(arr);	
            tabSelect(10);
            $('#dlercloud_login').show(); 
            $('#dlercloud_content').hide(); 	
		}
	});
    
}
//初始化页面时决定栏目显示哪个div层
function dc_init() {
    //初次未登录，显示登陆栏，此时token为空。
	//alert(db_merlinclash["merlinclash_dc_token"]);
    if(db_merlinclash["merlinclash_dc_token"] == "" || db_merlinclash["merlinclash_dc_token"] == null){
        $('#dlercloud_login').show();
        $('#dlercloud_content').hide();  
        return false;        
    }   
    //token失效，退回登陆栏；有效则重新获取最新的套餐信息
    if(db_merlinclash["merlinclash_dc_token"]){
        //alert(db_merlinclash["merlinclash_dc_token"]);
        var dbus_post = {};
        var arg="token"
        var id = parseInt(Math.random() * 100000000);
        var postData = {"id": id, "method": "clash_dclogin.sh", "params":[arg], "fields": dbus_post};
        $.ajax({
            type: "POST",
            url: "/_api/",
            async: true,
            data: JSON.stringify(postData),
            success: function(response) {
                var arr = response.result.split("@@");	
                //alert(arr);	
                if (arr[0] != "200"){
                    alert("DlerCloud用户/密码错，请重新登陆");
                    $('#dlercloud_login').show(); 
                    $('#dlercloud_content').hide(); 
                    return false;
                } else{
                    E("dc_name").innerHTML = arr[1];
					E("dc_token").innerHTML = arr[10];
					E("dc_money").innerHTML = arr[4];
					E("dc_affmoney").innerHTML = arr[11];
					E("dc_integral").innerHTML = arr[12];
					E("dc_plan").innerHTML = arr[2];
					
					E("dc_plantime").innerHTML = arr[3];
					
                    E("dc_usedTraffic").innerHTML = arr[5];
                    E("dc_unusedTraffic").innerHTML = arr[6];
                    E("dc_ss").innerHTML = arr[7];
                    E("dc_v2").innerHTML = arr[8];
                    E("dc_trojan").innerHTML = arr[9];  
                    $('#dlercloud_login').hide(); 
                    $('#dlercloud_content').show(); 
                    return false;                 
                }	    
            }
        });
    }
}
function dc_info() {
    //alert("登录成功");
    tabSelect(10);
    dc_info_show();
    $('#dlercloud_login').hide(); 
    $('#dlercloud_content').show(); 
    
}

function dc_info_show() {
    var dbus_post = {};
    var arg="info"
    var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dclogin.sh", "params":[arg], "fields": dbus_post};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			var arr = response.result.split("@@");	
            //alert(arr);	
            if (arr[0] != "200"){
                alert(arr[0]);
                return false;
            } else{
                E("dc_name").innerHTML = arr[1];
				E("dc_token").innerHTML = arr[10];
                E("dc_money").innerHTML = arr[4];
				E("dc_affmoney").innerHTML = arr[11];
				E("dc_integral").innerHTML = arr[12];
                E("dc_plan").innerHTML = arr[2];
                E("dc_plantime").innerHTML = arr[3];
                E("dc_usedTraffic").innerHTML = arr[5];
                E("dc_unusedTraffic").innerHTML = arr[6];
                E("dc_ss").innerHTML = arr[7];
                E("dc_v2").innerHTML = arr[8];
                E("dc_trojan").innerHTML = arr[9];
                
            }			
		}
	});
}


function clear_yaml() {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_clearyaml.sh", "params":[], "fields": ""};
	var yamlname=""
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
		}
	});
}
function get_hostyaml() {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_gethostyaml.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
		}
	});
}
function get_dnsyaml(dns_tag) {
	var id = parseInt(Math.random() * 100000000);
	var dbus_post={};
	dbus_post["merlinclash_dnsedit_tag"] = db_merlinclash["merlinclash_dnsedit_tag"] = dns_tag;
	var postData = {"id": id, "method": "clash_getdnsyaml.sh", "params":[], "fields": dbus_post};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			dns_yaml_view(dns_tag);
		}
	});
}
//获取dns-yaml
function dns_yaml_view(dns_tag) {
$.ajax({
		url: '/_temp/dns_' + dns_tag + '.txt',
		type: 'GET',
		dataType: 'html',
		async: true,
		cache:false,
		success: function(response) {
			//alert(response);
			var retArea = E("merlinclash_dns_edit_content1");
			retArea.value = response;
			
		},
		error: function(xhr) {
			E("merlinclash_dns_edit_content1").value = "获取dns配置文件失败！";
		}
	});
}
function upload_unblockmusicbinary() {

if(!$.trim($('#unblockmusicbinary').val())){
	alert("请先选择二进制文件");
	return false;
}

require(['/res/layer/layer.js'], function(layer) {
	layer.confirm('<li>请确保二进制文件合法！仍要上传吗？</li>', {
		shade: 0.8,
	}, function(index) {
		E('unblockmusicbinary_upload').style.display = "none";
		var formData = new FormData();
		formData.append("UnblockNeteaseMusic", document.getElementById('unblockmusicbinary').files[0]);
		$.ajax({
			url: '/_upload',
			type: 'POST',
			cache: false,
			data: formData,
			processData: false,
			contentType: false,
			complete: function(res) {
				if (res.status == 200) {
					upload_unblockmusic();
				}
			}
		});
		layer.close(index);
		return true;			
	}, function(index) {
		layer.close(index);
		return false;
		});
	});
}
function upload_unblockmusic() {
	var dbus_post = {};
	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "13"
	push_data("clash_local_unblockmusic_upload.sh", action,  dbus_post);
	E('unblockmusicbinary_upload').style.display = "block";
}
//------------------------------------------本地上传clash二进制 开始------------------------------------//
function upload_clashbinary() {

	if(!$.trim($('#clashbinary').val())){
		alert("请先选择clash文件");
		return false;
	}

	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>请确保clash二进制文件合法！仍要替换clash吗？</li>', {
			shade: 0.8,
		}, function(index) {
			E('clashbinary_upload').style.display = "none";
			var formData = new FormData();
			formData.append("clash", document.getElementById('clashbinary').files[0]);
			$.ajax({
				url: '/_upload',
				type: 'POST',
				cache: false,
				data: formData,
				processData: false,
				contentType: false,
				complete: function(res) {
					if (res.status == 200) {
						upload_binary();
					}
				}
			});
			layer.close(index);
			return true;			
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
	
	
}
function upload_binary() {
	var dbus_post = {};
	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "12"
	push_data("clash_local_binary_upload.sh", action,  dbus_post);
	E('clashbinary_upload').style.display = "block";
}
//------------------------------------------本地上传clash二进制 结束------------------------------------//
//------------------------------------------本地上传补丁 开始------------------------------------//
function upload_clashpatch() {

if(!$.trim($('#clashpatch').val())){
	alert("请先选择补丁包");
	return false;
}

require(['/res/layer/layer.js'], function(layer) {
	layer.confirm('<li>请确保补丁文件合法！仍要上传安装补丁吗？</li>', {
		shade: 0.8,
	}, function(index) {
		var patchname = $("#clashpatch").val();
		patchname = patchname.split('\\');
		patchname = patchname[patchname.length - 1];
		//var patchlast = patchname.split('.');
		//patchlast = patchlast[patchlast.length - 2];
		var lastindex = patchname.lastIndexOf('.')
		patchlast = patchname.substring(lastindex)
		//alert(patchname);
		//alert(patchlast);
		if (patchlast != ".gz") {
			alert('补丁包格式不正确！');
			return false;
		}
		E('clashpatch_upload').style.display = "none";
		var formData = new FormData();
		formData.append(patchname, document.getElementById('clashpatch').files[0]);
		$.ajax({
			url: '/_upload',
			type: 'POST',
			cache: false,
			data: formData,
			processData: false,
			contentType: false,
			complete: function(res) {
				if (res.status == 200) {
					upload_patch(patchname);
				}
			}
		});
		layer.close(index);
		return true;			
	}, function(index) {
		layer.close(index);
		return false;
	});
});


}
function upload_patch(patchname) {
	var dbus_post = {};
	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "15"
	dbus_post["merlinclash_uploadpatchname"] = db_merlinclash["merlinclash_uploadpatchname"] = patchname;
	push_data("clash_local_patch_upload.sh", action,  dbus_post);
	E('clashpatch_upload').style.display = "block";
}
//------------------------------------------本地上传补丁 结束------------------------------------//
//上传配置文件到/tmp/upload文件夹
//------------------------------------------本地上传配置 开始------------------------------------//
function upload_clashconfig() {
	var filename = $("#clashconfig").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length - 1];
	//alert(filename);
	if (filelast != "yaml") {
		alert('上传文件格式非法！只支持上传yaml后缀的配置文件');
		return false;
	}
	E('clashconfig_info').style.display = "none";
	var formData = new FormData();
	
	formData.append(filename, document.getElementById('clashconfig').files[0]);

	$.ajax({
		url: '/_upload',
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				upload_config(filename);
			}
		}
	});
}

//配置文件处理
function upload_config(filename) {
	var dbus_post = {};
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "3"
	dbus_post["merlinclash_uploadfilename"] = db_merlinclash["merlinclash_uploadfilename"] = filename;
	push_data("clash_config.sh", "upload",  dbus_post);
	E('clashconfig_info').style.display = "block";
	//yaml_select();
	//20200713
	yaml_select();
}
//------------------------------------------本地上传配置 结束------------------------------------//
//------------------------------------------上传HOST 开始---------------------------------------//
function upload_clashhost() {
	var filename = $("#clashhost").val();
	filename = filename.split('\\');
	filename = filename[filename.length - 1];
	var filelast = filename.split('.');
	filelast = filelast[filelast.length - 1];
	//alert(filename);
	if (filelast != "yaml") {
		alert('上传文件格式非法！只支持上传yaml后缀的hosts文件');
		return false;
	}
	E('clashhost_upload').style.display = "none";
	var formData = new FormData();
	
	filename_tmp="hosts.yaml"
	formData.append(filename_tmp, document.getElementById('clashhost').files[0]);

	$.ajax({
		url: '/_upload',
		type: 'POST',
		cache: false,
		data: formData,
		processData: false,
		contentType: false,
		complete: function(res) {
			if (res.status == 200) {
				upload_host(filename_tmp);
			}
		}
	});
}
function upload_host(filename_tmp) {
	var dbus_post = {};
	action = dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "22"
	dbus_post["merlinclash_uploadhost"] = db_merlinclash["merlinclash_uploadhost"] = filename_tmp;
	push_data("clash_local_host_upload.sh", action,  dbus_post);
	E('clashhost_upload').style.display = "block";
}
//------------------------------------------上传HOST 结束---------------------------------------//
function version_show() {
	if(!db_merlinclash["merlinclash_version_local"]) db_merlinclash["merlinclash_version_local"] = "0.0.0"
	$("#merlinclash_version_show").html("<a class='hintstyle'><i>当前版本：" + db_merlinclash['merlinclash_version_local'] + "</i></a>");
	$.ajax({
		url: 'https://raw.githubusercontent.com/flyhigherpi/merlinclash_hnd/master/config.json.js',
		type: 'GET',
		dataType: 'json',
		success: function(res) {
			if (typeof(res["version"]) != "undefined" && res["version"].length > 0) {
				//alert(res["version"]);
				var str=db_merlinclash["merlinclash_version_local"];
				//alert(str);
				var mvl_tmp=str.lastIndexOf('\.');
				var mvl=str.substring(0,mvl_tmp);
				var mscversion=db_merlinclash["merlinclash_scrule_version"];
				//var mcomversion=db_merlinclash["merlinclash_proxygroup_version"];
				//var mgameversion=db_merlinclash["merlinclash_proxygame_version"];
				//alert(mvl);
				if (versionCompare(res["version"], mvl)) {
					$("#updateBtn").html("<i>新版本：" + res.version + "</i>");
				}else{
						if (versionCompare(res["patch_version"], db_merlinclash["merlinclash_patch_version"])){ 
						$("#updateBtn").html("<i>新补丁：" + res.patch_version + "</i>");
					}
				}				
				//alert(res["sc_version"]);
				if (versionCompare(res["sc_version"], mscversion)) {
					$("#updatescBtn").html("<i>新版本,点我更新</i>");
				}
				//if (versionCompare(res["com_version"], mcomversion)) {
				//	$("#updatecomBtn").html("<i>新版本,点我更新</i>");
				//}
				//if (versionCompare(res["game_version"], mgameversion)) {
				//	$("#updategameBtn").html("<i>新版本,点我更新</i>");
				//}
			}
		}
	});
}
function dler_check() {
	var dbus_post = {};
	dbus_post["merlinclash_dlercloud_check"] = db_merlinclash["merlinclash_dlercloud_check"] = E("merlinclash_dlercloud_check").checked ? '1' : '0';
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": dbus_post};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			
		},
		success: function(response) {
			refreshpage();	
		}
	});	
}
function dnsfilechange() {
	var dbus_post = {};
	var dns_content = E("merlinclash_dns_edit_content1").value;
	var dns_base64 = "";
	//alert(dns_content);
	//return false;
	if(dns_content != ""){
		if(dns_content.search(/^dns:/) >= 0){
			//alert("OK");
			//return false;
			dns_base64 = Base64.encode(dns_content);
			//alert(dns_base64);
			//return false;
			dbus_post["merlinclash_dns_edit_content1"] = db_merlinclash["merlinclash_dns_edit_content1"] = dns_base64;
		}else{
			alert("dns区域内容有误，提交dns配置必须以dns:开头");
			return false;
		} 
	}else{
		alert("dns区域内容不能为空！！！");
		return false;
	}
	//alert(dbus_post["merlinclash_dns_edit_content1"]);
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dnsfilechange.sh", "params":[], "fields": dbus_post};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			
		},
		success: function(response) {
			refreshpage();	
		}
	});
}
function dnsfiles() {
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_dnsfiles.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		url: "/_api/",
		async: true,
		data: JSON.stringify(postData),
		success: function(response) {
			var arr = response.result.split("@");			
			E("merlinclash_rh_nameserver1").value = arr[0];
			E("merlinclash_rh_nameserver2").value = arr[1];
			E("merlinclash_rh_nameserver3").value = arr[2];
			E("merlinclash_rh_fallback1").value = arr[3];
			E("merlinclash_rh_fallback2").value = arr[4];
			E("merlinclash_rh_fallback3").value = arr[5];
			E("merlinclash_rhp_nameserver1").value = arr[6];
			E("merlinclash_rhp_nameserver2").value = arr[7];
			E("merlinclash_rhp_nameserver3").value = arr[8];
			E("merlinclash_rhp_fallback1").value = arr[9];
			E("merlinclash_rhp_fallback2").value = arr[10];
			E("merlinclash_rhp_fallback3").value = arr[11];
			E("merlinclash_fi_nameserver1").value = arr[12];
			E("merlinclash_fi_nameserver2").value = arr[13];
			E("merlinclash_fi_nameserver3").value = arr[14];
			E("merlinclash_fi_fallback1").value = arr[15];
			E("merlinclash_fi_fallback2").value = arr[16];
			E("merlinclash_fi_fallback3").value = arr[17];
		}
	});
}
//网易云定时重启
function unblock_restartjob_save() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_select_job"]	= db_merlinclash["merlinclash_select_job"] = E("merlinclash_select_job").value;
	dbus_post["merlinclash_select_day"]	= db_merlinclash["merlinclash_select_day"] = E("merlinclash_select_day").value;
	dbus_post["merlinclash_select_week"] = db_merlinclash["merlinclash_select_week"] = E("merlinclash_select_week").value;
	dbus_post["merlinclash_select_hour"] = db_merlinclash["merlinclash_select_hour"] = E("merlinclash_select_hour").value;
	dbus_post["merlinclash_select_minute"] = db_merlinclash["merlinclash_select_minute"] = E("merlinclash_select_minute").value;	 
	var postData = {"id": id, "method": "clash_unblock_restartjob.sh", "params":[], "fields": dbus_post};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			
		},
		success: function(response) {
			refreshpage();	
		}
	});
}
//定时订阅
function regular_subscribe_save() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_select_regular_subscribe"]	= db_merlinclash["merlinclash_select_regular_subscribe"] = E("merlinclash_select_regular_subscribe").value;
	dbus_post["merlinclash_select_regular_day"]	= db_merlinclash["merlinclash_select_regular_day"] = E("merlinclash_select_regular_day").value;
	dbus_post["merlinclash_select_regular_week"] = db_merlinclash["merlinclash_select_regular_week"] = E("merlinclash_select_regular_week").value;
	dbus_post["merlinclash_select_regular_hour"] = db_merlinclash["merlinclash_select_regular_hour"] = E("merlinclash_select_regular_hour").value;
	dbus_post["merlinclash_select_regular_minute"] = db_merlinclash["merlinclash_select_regular_minute"] = E("merlinclash_select_regular_minute").value;	 
	dbus_post["merlinclash_select_regular_minute_2"] = db_merlinclash["merlinclash_select_regular_minute_2"] = E("merlinclash_select_regular_minute_2").value;
	var postData = {"id": id, "method": "clash_regular_subscribe.sh", "params":[], "fields": dbus_post};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			
		},
		success: function(response) {
			refreshpage();	
		}
	});
}
//定时重启
function clash_restart_save() {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_select_clash_restart"]	= db_merlinclash["merlinclash_select_clash_restart"] = E("merlinclash_select_clash_restart").value;
	dbus_post["merlinclash_select_clash_restart_day"]	= db_merlinclash["merlinclash_select_clash_restart_day"] = E("merlinclash_select_clash_restart_day").value;
	dbus_post["merlinclash_select_clash_restart_week"] = db_merlinclash["merlinclash_select_clash_restart_week"] = E("merlinclash_select_clash_restart_week").value;
	dbus_post["merlinclash_select_clash_restart_hour"] = db_merlinclash["merlinclash_select_clash_restart_hour"] = E("merlinclash_select_clash_restart_hour").value;
	dbus_post["merlinclash_select_clash_restart_minute"] = db_merlinclash["merlinclash_select_clash_restart_minute"] = E("merlinclash_select_clash_restart_minute").value;	 
	dbus_post["merlinclash_select_clash_restart_minute_2"] = db_merlinclash["merlinclash_select_clash_restart_minute_2"] = E("merlinclash_select_clash_restart_minute_2").value;
	var postData = {"id": id, "method": "clash_restart_regularly.sh", "params":[], "fields": dbus_post};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			
		},
		success: function(response) {
			refreshpage();	
		}
	});
}
function unblock_restart() {
	var dbus_post = {};
	if(db_merlinclash["merlinclash_UnblockNeteaseMusic_version"] >= "0.2.5"){
		dbus_post["merlinclash_unblockmusic_platforms_numbers"] = db_merlinclash["merlinclash_unblockmusic_platforms_numbers"] = E("merlinclash_unblockmusic_platforms_numbers").value;
	}
	dbus_post["merlinclash_unblockmusic_endpoint"] = db_merlinclash["merlinclash_unblockmusic_endpoint"] = E("merlinclash_unblockmusic_endpoint").value;
	dbus_post["merlinclash_unblockmusic_musicapptype"] = db_merlinclash["merlinclash_unblockmusic_musicapptype"] = E("merlinclash_unblockmusic_musicapptype").value;	
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = "8"

	push_data("clash_config.sh", "unblockmusicrestart",  dbus_post);	
}
function createcert(action) {
	var dbus_post = {};
	var id = parseInt(Math.random() * 100000000);
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_unblockmusic_createcrt.sh", action, dbus_post);
}
function downloadcert() {
	var dbus_post = {};
	//alert(dbus_post["merlinclash_delyamlsel"]);
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_unblockmusic_cert.sh", "params":[], "fields": dbus_post};
	var cert=""
	$.ajax({
			type: "POST",
			cache:false,
			url: "/_api/",
			data: JSON.stringify(postData),
			dataType: "json",
			success: function(response) {
				cert = response.result;
				download_cert(cert);
			}
	});	
}
function download_cert(cert) {
	var a= "http://"+window.location.hostname+"/_temp/"+cert;
	var downloadA = document.createElement('a');
	var josnData = {};
	var blob = new Blob([JSON.stringify(josnData)],{type : 'application/json'});
	//downloadA.href = window.URL.createObjectURL(blob);
	downloadA.href = a
	downloadA.download = cert;
	downloadA.click();
	window.URL.revokeObjectURL(downloadA.href);
}
function geoip_update(action){
	var dbus_post = {};
	var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
            + " " + date.getHours() + seperator2 + date.getMinutes()
            + seperator2 + date.getSeconds();
	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>你确定要更新GeoIP数据库吗？</li>', {
			shade: 0.8,
		}, function(index) {
			$("#log_content3").attr("rows", "20");
			dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
			dbus_post["merlinclash_updata_date"] = db_merlinclash["merlinclash_updata_date"] = currentdate;
			push_data("clash_update_ipdb.sh", action, dbus_post);
			E("geoip_updata_date").innerHTML = "<span style='color: gold'>上次更新时间："+db_merlinclash["merlinclash_updata_date"]+"</span>";
			layer.close(index);
			return true;
			
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
}

//在线更新clash二进制，已废弃
function clash_update(action){
	var dbus_post = {};
	var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
            + " " + date.getHours() + seperator2 + date.getMinutes()
            + seperator2 + date.getSeconds();
	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>你确定要更新clash二进制吗？</li>', {
			shade: 0.8,
		}, function(index) {
			$("#log_content3").attr("rows", "20");
			dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
			dbus_post["merlinclash_update_clashdate"] = db_merlinclash["merlinclash_update_clashdate"] = currentdate;
			push_data("clash_update_clashbinary.sh", action, dbus_post);
			E("clash_update_date").innerHTML = "<span style='color: gold'>&nbsp;&nbsp;上次更新时间："+db_merlinclash["merlinclash_update_clashdate"]+"</span>";
			layer.close(index);
			return true;
			
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
}
function proxygroup_update(action) {
	var dbus_post = {};
	var date = new Date();
    var seperator1 = "-";
    var seperator2 = ":";
    var month = date.getMonth() + 1;
    var strDate = date.getDate();
    if (month >= 1 && month <= 9) {
        month = "0" + month;
    }
    if (strDate >= 0 && strDate <= 9) {
        strDate = "0" + strDate;
    }
    var currentdate = date.getFullYear() + seperator1 + month + seperator1 + strDate
            + " " + date.getHours() + seperator2 + date.getMinutes()
            + seperator2 + date.getSeconds();
	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>你确定要更新内置规则文件吗？</li>', {
			shade: 0.8,
		}, function(index) {
			$("#log_content3").attr("rows", "20");
			dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
			//dbus_post["merlinclash_update_proxygroupdate"] = db_merlinclash["merlinclash_update_proxygroupdate"] = currentdate;
			push_data("clash_update_proxygroup.sh", action, dbus_post);
			
			//E("proxygroup_update_date").innerHTML = "<span style='color: gold'>&nbsp;&nbsp;上次更新时间："+db_merlinclash["merlinclash_update_proxygroupdate"]+"</span>";
			layer.close(index);
			return true;
			
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
}
function proxygame_update(action) {
	var dbus_post = {};
	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>你确定要更新内置游戏规则文件吗？</li>', {
			shade: 0.8,
		}, function(index) {
			$("#log_content3").attr("rows", "20");
			dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
			//dbus_post["merlinclash_update_proxygroupdate"] = db_merlinclash["merlinclash_update_proxygroupdate"] = currentdate;
			push_data("clash_update_proxygroup.sh", action, dbus_post);
			
			//E("proxygroup_update_date").innerHTML = "<span style='color: gold'>&nbsp;&nbsp;上次更新时间："+db_merlinclash["merlinclash_update_proxygroupdate"]+"</span>";
			layer.close(index);
			return true;
			
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
}
function sc_update(action) {
	var dbus_post = {};
	require(['/res/layer/layer.js'], function(layer) {
		layer.confirm('<li>你确定要更新subconverter规则文件吗？</li>', {
			shade: 0.8,
		}, function(index) {
			$("#log_content3").attr("rows", "20");
			dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
			push_data("clash_update_sc.sh", action, dbus_post);
			layer.close(index);
			return true;
			
		}, function(index) {
			layer.close(index);
			return false;
		});
	});
}
function doalert(id){
  if(this.checked) {
     alert('checked');
  }else{
     alert('unchecked');
  }
}
function clash_getversion(action) {
	var dbus_post = {};
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	push_data("clash_get_binary_history.sh", action, dbus_post);
}
function clash_replace(action) {
	if(!$.trim($('#merlinclash_clashbinarysel').val())){
		alert("请选择二进制版本");
		return false;
	}
	var dbus_post = {};
	dbus_post["merlinclash_action"] = db_merlinclash["merlinclash_action"] = action;
	dbus_post["merlinclash_clashbinarysel"] = db_merlinclash["merlinclash_clashbinarysel"] = E("merlinclash_clashbinarysel").value;
	push_data("clash_get_binary_history.sh", action, dbus_post);
}
//----------------下拉框获取配置文件名BEGIN--------------------------
function yaml_select(){	
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_getyamls.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				yaml_select_get();
				
			}
		}
	});
}

function yaml_select_get() {
	
	$.ajax({
		url: '/_temp/yamls.txt',		
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Myselect(arr);
		}
	});
}
var counts;
counts=0;
function Myselect(arr){
	var i;
	counts=arr.length;
	var yamllist = arr;  	
	$("#merlinclash_yamlsel").append("<option value=''>--请选择--</option>");
	$("#merlinclash_delyamlsel").append("<option value=''>--请选择--</option>");
	
	for(i=0;i<yamllist.length-1;i++){
		var a=yamllist[i];
		$("#merlinclash_yamlsel").append("<option value='"+a+"' >"+a+"</option>");
		$("#merlinclash_delyamlsel").append("<option value='"+a+"' >"+a+"</option>");
	}
}
//----------------下拉框获取配置文件名END--------------------------
//----------------下拉框获取clash版本号BEGIN--------------------------
function clashbinary_select(){	
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_getclashbinary.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				clashbinary_select_get();
				
			}
		}
	});
}

function clashbinary_select_get() {
	
	$.ajax({
		url: '/_temp/clash_binary_history.txt',		
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Myclashbinary(arr);
		}
	});
}
var binarys;
binarys=0;
function Myclashbinary(arr){
	var k;
	binarys=arr.length;
	var binarylist = arr;  	
	$("#merlinclash_clashbinarysel").append("<option value=''>---------请选择---------</option>");
	for(k=0;k<binarylist.length;k++){
		var a=binarylist[k];
		$("#merlinclash_clashbinarysel").append("<option value='"+a+"' >"+a+"</option>");
	}
}
//----------------下拉框获取clash版本号END--------------------------
//----------------------------proxy-group 下拉框部分代码BEGIN-------------------------//
function proxygroup_select(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_getproxygroup.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				proxygroup_select_get();
			}
		}
	});
}
function proxygroup_select_get() {
	$.ajax({
		url: '/_temp/proxygroups.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			Mypgselect(arr);
		}
	});
}
var pgcounts;
pgcounts=0;
function Mypgselect(arr){
	var i;
	pgcounts=arr.length;
	var pglist = arr;  
	   	$("#merlinclash_acl_lianjie").append("<option value=''>--请选择--</option>");
	for(i=0;i<pglist.length-1;i++){
		var a=pglist[i];
		$("#merlinclash_acl_lianjie").append("<option value='"+a+"' >"+a+"</option>");
	}
}

function nproxygroup_select_get(node) {
	$.ajax({
		url: '/_temp/proxygroups.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			//alert(node);
			nMypgselect(arr,node);
		}
	});
}
function nproxies_select_get(node) {
	$.ajax({
		url: '/_temp/proxies.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arr = response.split("\n");
			//alert(node);
			nMypxselect(arr,node);
		}
	});
}

function nMypgselect(arr,node){
	var npgcounts;
	var i;
	npgcounts=arr.length;
	var p = "merlinclash_npgnodes";
	var pgnodes = {};
	var params = ["proxygroup"];
	for (var j = 0; j < params.length; j++) {
		$("#pgnodes_tr_" + node + " input[name='"+ p +"_" + params[j] + "_" + node+ "']").each(function () {
			pgnodes[p + "_" + params[j] + "_" + node] = this.value;
		});
	}
	//alert(pgnodes[p + "_" + params[0] + "_" + node]);
	var b = pgnodes[p + "_" + params[0] + "_" + node];
	var npglist = arr;  
	//$("#merlinclash_pgnodes_proxygroup_" + node).append("<option value=''>--请选择--</option>");

	for(i=0;i<npglist.length-1;i++){
		var a=npglist[i];
		$("#merlinclash_pgnodes_proxygroup_" + node).append("<option value='"+a+"' >"+a+"</option>");
	}
	$("#merlinclash_pgnodes_proxygroup_"+node).find("option[value = '"+b+"']").attr("selected","selected");
}
function nMypxselect(arr,node){
	var npxcounts;
	var i;
	npxcounts=arr.length;
	var p = "merlinclash_npgnodes";
	var pxnodes = {};
	var params = ["nodesel"];
	for (var j = 0; j < params.length; j++) {
		$("#pgnodes_tr_" + node + " input[name='"+ p +"_" + params[j] + "_" + node+ "']").each(function () {
			pxnodes[p + "_" + params[j] + "_" + node] = this.value;
		});
	}
	//alert(pxnodes[p + "_" + params[0] + "_" + node]);
	var c = pxnodes[p + "_" + params[0] + "_" + node];
	var npglist = arr;  
	//$("#merlinclash_pgnodes_nodesel_" + node).append("<option value=''>--请选择--</option>");
	
	for(i=0;i<npglist.length-1;i++){
		var a=npglist[i];
		$("#merlinclash_pgnodes_nodesel_" + node).append("<option value='"+a+"' >"+a+"</option>");	
	}
	$("#merlinclash_pgnodes_nodesel_"+node).find("option[value = '"+c+"']").attr("selected","selected");

}
//----------------------------proxy-group下拉框部分代码END--------------------------//
//----------------------------proxies下拉框部分代码BEGIN----------------------------//
function proxies_select(){
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "clash_getproxies.sh", "params":[], "fields": ""};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {
			if(response.result == id){
				proxies_select_get();
			}
		}
	});
}
function proxies_select_get() {
	$.ajax({
		url: '/_temp/proxies.txt',
		type: 'GET',
		cache:false,
		dataType: 'text',
		success: function(response) {
			//按换行符切割
			var arrb = response.split("\n");
			Mypxselect(arrb);
		}
	});
}
var pxcounts;
pxcounts=0;
function Mypxselect(arrb){
	var i;
	pxcounts=arrb.length;
	var pxlist = arrb;  
		$("#merlinclash_pgnodes_nodesel").append("<option value=''>--请选择--</option>");
	for(i=0;i<pxlist.length-1;i++){
		var a=pxlist[i];
		$("#merlinclash_pgnodes_nodesel").append("<option value='"+a+"' >"+a+"</option>");
	    }
}
//----------------------------proxies下拉框部分代码END------------------------------//
//----------------------------ACL代码部分BEGIN--------------------------------------//
function refresh_acl_table(q) {
$.ajax({
	type: "GET",
	url: "/_api/merlinclash_acl",
	dataType: "json",
	async: false,
	success: function(data) {
		db_acl = data.result[0];
		refresh_acl_html();
			
		//write dynamic table value
		for (var i = 1; i < acl_node_max + 1; i++) {
			$('#merlinclash_acl_type_' + i).val(db_acl["merlinclash_acl_type_" + i]);
			$('#merlinclash_acl_content_' + i).val(db_acl["merlinclash_acl_content_" + i]);
			$('#merlinclash_acl_lianjie_' + i).val(db_acl["merlinclash_acl_lianjie_" + i]);
			
		}
		//after table generated and value filled, set default value for first line_image1
		$('#merlinclash_acl_type').val("SRC-IP-CIDR");
	}
});
}
function addTr() {
	if(!$.trim($('#merlinclash_acl_content').val())){
		alert("内容不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_acl_lianjie').val())){
		alert("连接方式不能为空！");
		return false;
	}
	var acls = {};
	var p = "merlinclash_acl";
	acl_node_max += 1;
	var params = ["type", "content", "lianjie"];
	for (var i = 0; i < params.length; i++) {
		acls[p + "_" + params[i] + "_" + acl_node_max] = Base64.encode(encodeURIComponent($('#' + p + "_" + params[i]).val()));
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": acls};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_acl_table();
			proxygroup_select_get();
			E("merlinclash_acl_content").value = ""
			E("merlinclash_acl_lianjie").value = ""
		}
	});
	aclid = 0;
}
function delTr(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_acl";
	id = ids[ids.length - 1];
	var acls = {};
	var params = ["type", "content", "lianjie"];
	for (var i = 0; i < params.length; i++) {
		db_merlinclash[p + "_" + params[i] + "_" + id] =acls[p + "_" + params[i] + "_" + id] = "";
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": acls};

	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {			
			refresh_acl_table();
			proxygroup_select_get();
			//refreshpage();
		}
	});
}
//自定规则
function refresh_acl_html() {
	acl_confs = getACLConfigs();
	var n = 0;
	for (var i in acl_confs) {
		n++;
	}
	var code = '';
	// acl table th
	code += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table acl_lists" style="margin:-1px 0px 0px 0px;">'
	code += '<tr>'
	code += '<th width="30%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(2)">类型</a></th>'
	code += '<th width="40%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(3)">内容</a></th>'
	code += '<th width="20%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(4)">连接方式</a></th>'
	code += '<th width="10%">操作</th>'
	code += '</tr>'
	code += '</table>'
	// acl table input area
	code += '<table id="ACL_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table acl_lists" style="margin:-1px 0px 0px 0px;">'
		code += '<tr>'
	//类型 
			code += '<td width="30%">'
			code += '<select id="merlinclash_acl_type" style="width:140px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
			code += '<option value="SRC-IP-CIDR">SRC-IP-CIDR</option>'
			code += '<option value="IP-CIDR">IP-CIDR</option>'
			code += '<option value="DOMAIN-SUFFIX">DOMAIN-SUFFIX</option>'
			code += '<option value="DOMAIN">DOMAIN</option>'
			code += '<option value="DOMAIN-KEYWORD">DOMAIN-KEYWORD</option>'
			code += '<option value="DST-PORT">DST-PORT</option>'
			code += '<option value="SRC-PORT">SRC-PORT</option>'
			//code += '<option value="MATCH">MATCH</option>'
			code += '</select>'
			code += '</td>'
	//内容
			code += '<td width="40%">'
			code += '<input type="text" id="merlinclash_acl_content" class="input_ss_table" maxlength="50" style="width:200px;text-align:center" placeholder="" />'
			code += '</td>'
	//连接
			code += '<td width="20%">'
	//		code += '<input type="text" id="merlinclash_acl_lianjie" class="input_ss_table" maxlength="50" style="width:140px;text-align:center" placeholder="" />'
				code += '<select id="merlinclash_acl_lianjie" style="width:140px;margin:0px 0px 0px 2px;text-align:center;text-align-last:center;padding-left: 12px;" class="input_option">'
				code += '</select>'
			code += '</td>'	
	// add/delete 按钮
			code += '<td width="10%">'
			code += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="addTr()" value="" />'
			code += '</td>'
		code += '</tr>'
	// acl table rule area
	for (var field in acl_confs) {
		var ac = acl_confs[field];		
		code += '<tr id="acl_tr_' + ac["acl_node"] + '">';
			code += '<td width="30%" id="merlinclash_acl_type_' +ac["acl_node"] + '">' + ac["type"] + '</td>';
			code += '<td width="40%" id="merlinclash_acl_content_' +ac["acl_node"] + '">' + ac["content"] + '</td>';
			code += '<td width="20%" id="merlinclash_acl_lianjie_' +ac["acl_node"] + '">' + ac["lianjie"] + '</td>';			
			
			code += '<td width="10%">';
				code += '<input style="margin: -2px 0px -4px -2px;" id="acl_node_' + ac["acl_node"] + '" class="remove_btn" type="button" onclick="delTr(this);" value="">'
			code += '</td>';
		code += '</tr>';
	}
	code += '</table>';

	$(".acl_lists").remove();
	$('#merlinclash_acl_table').after(code);

}
function getACLConfigs() {
	var dict = {};
	//acl_node_max = 0;
	for (var field in db_acl) {
		names = field.split("_");
		
		dict[names[names.length - 1]] = 'ok';
	}
	acl_confs = {};
	var p = "merlinclash_acl";
	var params = ["type", "content", "lianjie"];
	for (var field in dict) {
		var obj = {};
		for (var i = 0; i < params.length; i++) {
			var ofield = p + "_" + params[i] + "_" + field;
			if (typeof db_acl[ofield] == "undefined") {
				obj = null;
				break;
			}
			obj[params[i]] = decodeURIComponent(Base64.decode(db_acl[ofield]));
			
		}
		if (obj != null) {
			var node_a = parseInt(field);
			if (node_a > acl_node_max) {
				acl_node_max = node_a;
			}
			obj["acl_node"] = field;
			acl_confs[field] = obj;
		}
	}
	return acl_confs;
}
//----------------------------ACL代码部分END--------------------------------------//

//----------------------------DEVICE代码部分BEGIN--------------------------------------//
function refresh_device_table(q) {
$.ajax({
	type: "GET",
	url: "/_api/merlinclash_device",
	dataType: "json",
	async: false,
	success: function(data) {
		db_device = data.result[0];
		refresh_device_html();
			
		//write dynamic table value
		for (var i = 1; i < acl_node_max + 1; i++) {
			$('#merlinclash_device_ip_' + i).val(db_acl["merlinclash_device_ip_" + i]);
			$('#merlinclash_device_name_' + i).val(db_acl["merlinclash_device_name_" + i]);	
			$('#merlinclash_device_mode_' + i).val(db_acl["merlinclash_device_mode_" + i]);	
		}
		//after table generated and value filled, set default value for first line_image1
		//$('#merlinclash_device_ip_').val("SRC-IP-CIDR");
	}
});
}
function adddeviceTr() {
	if(!$.trim($('#merlinclash_device_ip').val())){
		alert("主机IP地址不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_device_name').val())){
		alert("主机别名不能为空！");
		return false;
	}
	var devices = {};
	var p = "merlinclash_device";
	devices_node_max += 1;
	var params = ["ip", "name", "mode"];
	for (var i = 0; i < params.length; i++) {
		devices[p + "_" + params[i] + "_" + devices_node_max] = Base64.encode($('#' + p + "_" + params[i]).val());
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": devices};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_device_table();
			E("merlinclash_device_ip").value = ""
			E("merlinclash_device_name").value = ""
		}
	});
	deviceid = 0;
}
function deldeviceTr(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_device";
	id = ids[ids.length - 1];
	var devices = {};
	var params = ["ip", "name", "mode"];
	for (var i = 0; i < params.length; i++) {
		db_merlinclash[p + "_" + params[i] + "_" + id] = devices[p + "_" + params[i] + "_" + id] = "";
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": devices};

	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {			
			refresh_device_table();
			//refreshpage();
		}
	});
}
//设备绕行
function refresh_device_html() {
	device_confs = getDEVICEConfigs();
	var n = 0;
	for (var i in device_confs) {
		n++;
	}
	var code = '';
	// acl table th
	code += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table device_lists" style="margin:-1px 0px 0px 0px;">'
	code += '<tr>'
	code += '<th width="25%" style="text-align: center; vertical-align: middle;">主机IP地址</th>'
	code += '<th width="25%" style="text-align: center; vertical-align: middle;">主机别名</th>'
	code += '<th width="10%" style="text-align: center; vertical-align: middle;"><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(15)">绕行模式</a></th>'
	code += '<th width="15%">操作</th>'
	code += '</tr>'
	code += '</table>'
	// acl table input area
	code += '<table id="DEVICE_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table device_lists" style="margin:-1px 0px 0px 0px;">'
		code += '<tr>'
	//主机IP地址 
			code += '<td width="25%">'
			code += '<input type="text" maxlength="15" class="input_ss_table" id="merlinclash_device_ip" align="left" style="float:center;width:205px;text-align:center" autocomplete="off" onClick="hideClients_Block();" autocorrect="off" autocapitalize="off">'
			code += '<img id="pull_arrow" height="14px;" src="images/arrow-down.gif" style="float:right;" align="right" onclick="pullLANIPList(this);" title="<#select_IP#>">'
			code += '<div id="ClientList_Block" class="clientlist_dropdown" style="margin-left:2px;width:235px;"></div>'
			code += '</td>'
	//主机别名
			code += '<td width="25%">'
			code += '<input type="text" id="merlinclash_device_name" class="input_ss_table" align="center" maxlength="50" style="width:200px;text-align:center" placeholder="" />'
			code += '</td>'
	//绕行模式
			code += '<td width="10%">'
			code += '<select id="merlinclash_device_mode" style="width:80px;margin:0px 0px 0px 2px;text-align:middle;padding-left: 0px;" class="input_option">'
			code +=	'<option value="M模式">M模式</option>'
			code +=	'<option value="P模式">P模式</option>'																																					
			code +=	'</select>'
			code += '</td>'
	// add/delete 按钮
			code += '<td width="15%">'
			code += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="adddeviceTr()" value="" />'
			code += '</td>'
		code += '</tr>'
	// 
	for (var field in device_confs) {
		var dc = device_confs[field];		
		code += '<tr id="device_tr_' + dc["device_node"] + '">';
			code += '<td width="25%" id="merlinclash_device_ip_' +dc["device_node"] + '">' + dc["ip"] + '</td>';
			code += '<td width="25%" id="merlinclash_device_name_' +dc["device_node"] + '">' + dc["name"] + '</td>';
			code += '<td width="10%" id="merlinclash_device_mode_' +dc["device_node"] + '">' + dc["mode"] + '</td>';
			code += '<td width="15%">';
				code += '<input style="margin: -2px 0px -4px -2px;" id="acl_node_' + dc["device_node"] + '" class="remove_btn" type="button" onclick="deldeviceTr(this);" value="">'
			code += '</td>';
		code += '</tr>';
	}
	code += '</table>';

	$(".device_lists").remove();
	$('#merlinclash_device_table').after(code);

	showDropdownClientList('setClientIP', 'ip', 'all', 'ClientList_Block', 'pull_arrow', 'online');
}
function setClientIP(ip, name, mac) {
	E("merlinclash_device_ip").value = ip;
	E("merlinclash_device_name").value = name;
	hideClients_Block();
}
function pullLANIPList(obj) {
	var element = E('ClientList_Block');
	var isMenuopen = element.offsetWidth > 0 || element.offsetHeight > 0;
	if (isMenuopen == 0) {
		obj.src = "/images/arrow-top.gif"
		element.style.display = 'block';
	} else{
		hideClients_Block();
	}
}
function hideClients_Block() {
	E("pull_arrow").src = "/images/arrow-down.gif";
	E('ClientList_Block').style.display = 'none';
}
function getDEVICEConfigs() {
	var dict = {};
	devices_node_max = 0;
	for (var field in db_device) {
		names = field.split("_");
		
		dict[names[names.length - 1]] = 'ok';
	}
	device_confs = {};
	var p = "merlinclash_device";
	var params = ["ip", "name", "mode"];
	for (var field in dict) {
		var obj = {};
		for (var i = 0; i < params.length; i++) {
			var ofield = p + "_" + params[i] + "_" + field;
			if (typeof db_device[ofield] == "undefined") {
				obj = null;
				break;
			}
			obj[params[i]] = Base64.decode(db_device[ofield]);
			
		}
		if (obj != null) {
			var node_a = parseInt(field);
			if (node_a > devices_node_max) {
				devices_node_max = node_a;
			}
			obj["device_node"] = field;
			device_confs[field] = obj;
		}
	}
	return device_confs;
}
//----------------------------DEVICE代码部分END--------------------------------------//

//----------------------------KCP代码部分BEGIN--------------------------------------//
function refresh_kcp_table(q) {
	$.ajax({
		type: "GET",
		url: "/_api/merlinclash_kcp",
		dataType: "json",
		async: false,
		success: function(data) {
			db_kcp = data.result[0];
			refresh_kcp_html();
				
			//write dynamic table value
			for (var i = 1; i < kcp_node_max + 1; i++) {
				$('#merlinclash_kcp_lport_' + i).val(db_acl["merlinclash_kcp_lport_" + i]);
				$('#merlinclash_kcp_server_' + i).val(db_acl["merlinclash_kcp_server_" + i]);
				$('#merlinclash_kcp_port_' + i).val(db_acl["merlinclash_kcp_port_" + i]);
				$('#merlinclash_kcp_param_' + i).val(db_acl["merlinclash_kcp_param_" + i]);
			}
			//after table generated and value filled, set default value for first line_image1
		}
	});
}
function addTrkcp() {
	var kcps = {};
	var p = "merlinclash_kcp";
	kcp_node_max += 1;
	var params = ["lport", "server", "port", "param"];
	for (var i = 0; i < params.length; i++) {
		kcps[p + "_" + params[i] + "_" + kcp_node_max] = $('#' + p + "_" + params[i]).val();
		
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": kcps};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_kcp_table();
			E("merlinclash_kcp_lport").value = ""
			E("merlinclash_kcp_server").value = ""
			E("merlinclash_kcp_port").value = ""
			E("merlinclash_kcp_param").value = ""
		}
	});
	kcpid = 0;
}
function saveTrkcp(o) {
	var id = $(o).attr("id"); //kcp_nodes_1
	var ids = id.split("_");
	var p = "merlinclash_kcp";
	id = ids[ids.length - 1];
	var kcps = {};
	var params = ["lport", "server", "port", "param"];


	for (var i = 0; i < params.length; i++) {
		$("#kcp_tr_" + id + " input[name='"+ p +"_" + params[i] + "_" + id+ "']").each(function () {
			kcps[p + "_" + params[i] + "_" + id] = this.value;
		});
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": kcps};

	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {		
			refresh_kcp_table();
			refreshpage();
		}
	});	
}
function delTrkcp(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_kcp";
	id = ids[ids.length - 1];
	var kcps = {};
	var params = ["lport", "server", "port", "param"];
	for (var i = 0; i < params.length; i++) {
		kcps[p + "_" + params[i] + "_" + id] = "";
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": kcps};

	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {		           
			refresh_kcp_table();
			refreshpage();
		}
	});
}
function refresh_kcp_html() {
	kcp_confs = getkcpConfigs();
	var n = 0;
	for (var i in kcp_confs) {
		n++;
	}
	var code2 = '';
	// kcp table th
	code2 += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table kcp_lists" style="margin:-1px 0px 0px 0px;">'
		code2 += '<tr>'
			code2 += '<th width="10%" style="text-align: center; vertical-align: middle;">监听端口</th>'
			code2 += '<th width="20%" style="text-align: center; vertical-align: middle;">kcp服务器</th>'
			code2 += '<th width="10%" style="text-align: center; vertical-align: middle;">kcp端口</th>'
			code2 += '<th width="40%" style="text-align: center; vertical-align: middle;">kcp参数</th>'
			code2 += '<th width="20%">操作</th>'
		code2 += '</tr>'
	code2 += '</table>'
	// kcp table input area
	code2 += '<table id="KCP_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table kcp_lists" style="margin:-1px 0px 0px 0px;">'
		code2 += '<tr>'
	//监听端口
			code2 += '<td width="10%">'
				code2 += '<input type="text" id="merlinclash_kcp_lport" class="input_ss_table" maxlength="6" style="width:80%;text-align:center;" placeholder="" />'
			code2 += '</td>'
	//KCP服务器 
			code2 += '<td width="20%">'
				code2 += '<input type="text" id="merlinclash_kcp_server" class="input_ss_table" maxlength="20" style="width:90%;text-align:center;" placeholder="" />'
			code2 += '</td>'
	//端口
			code2 += '<td width="10%">'
				code2 += '<input type="text" id="merlinclash_kcp_port" class="input_ss_table" maxlength="6" style="width:80%;text-align:center;" placeholder="" />'
			code2 += '</td>'
	//参数
			code2 += '<td width="40%">'
				code2 += '<input type="text" id="merlinclash_kcp_param" class="input_ss_table" maxlength="5000" style="width:90%;text-align:center;" placeholder="" />'
				code2 += '</td>'	
	// add/delete 按钮
			code2 += '<td width="20%">'
				code2 += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="addTrkcp()" value="" />'
			code2 += '</td>'
		code2 += '</tr>'
	// kcp table data area
	for (var field in kcp_confs) {
		var kc = kcp_confs[field];		
		code2 += '<tr id="kcp_tr_' + kc["kcp_node"] + '">';
			code2 += '<td width="10%">'
				code2 += '<input type="text" id="merlinclash_kcp_lport_' + kc["kcp_node"] +' "name="merlinclash_kcp_lport_' + kc["kcp_node"] +'" class="input_option_2" maxlength="6" style="width:80%;text-align:center;" value="' + kc["lport"] +'" />'
			code2 += '</td>';
			code2 += '<td width="20%">'
				code2 += '<input type="text" id="merlinclash_kcp_server_' + kc["kcp_node"] +' "name="merlinclash_kcp_server_' + kc["kcp_node"] +'" class="input_option_2" maxlength="20" style="width:90%;text-align:center;" value="' + kc["server"] +'" />'
			code2 += '</td>';
			code2 += '<td width="10%">'
				code2 += '<input type="text" id="merlinclash_kcp_port_' + kc["kcp_node"] +' "name="merlinclash_kcp_port_' + kc["kcp_node"] +'" class="input_option_2" maxlength="6" style="width:80%;text-align:center;" value="' + kc["port"] +'" />'
			code2 += '</td>';
			code2 += '<td width="40%">'
				code2 += '<input type="text" id="merlinclash_kcp_param_' + kc["kcp_node"] +' "name="merlinclash_kcp_param_' + kc["kcp_node"] +'" class="input_option_2" maxlength="5000" style="width:90%;text-align:center;" value="' + kc["param"] +'" />'
				code2 += '</td>';
			code2 += '<td width="20%">';
				code2 += '<input style="margin: 0px 0px -4px -2px;" id="kcp_nodes_' + kc["kcp_node"] + '" class="edit_btn" type="button" onclick="saveTrkcp(this);" value="">'
				code2 += ' '
				code2 += '<input style="margin: 0px 0px -4px -2px;" id="kcp_noded_' + kc["kcp_node"] + '" class="remove_btn" type="button" onclick="delTrkcp(this);" value="">'
				//code2 += '<input style="width:60px" id="kcp_nodes_' + kc["kcp_node"] + '" class="ss_btn" type="button" onclick="saveTrkcp(this);" value="保存">'
				//code2 += ' '
				//code2 += '<input style="width:60px" id="kcp_noded_' + kc["kcp_node"] + '" class="ss_btn" type="button" onclick="delTrkcp(this);" value="删除">'
			code2 += '</td>';
		code2 += '</tr>';
	}
	code2 += '</table>';

	$(".kcp_lists").remove();
	$('#merlinclash_kcp_table').after(code2);

}
function getkcpConfigs() {
	var dictkcp = {};
	kcp_node_max = 0;
	for (var field in db_kcp) {
		kcpnames = field.split("_");
		
		dictkcp[kcpnames[kcpnames.length - 1]] = 'ok';
	}
	kcp_confs = {};
	var p = "merlinclash_kcp";
	var params = ["lport", "server", "port", "param"];
	for (var field in dictkcp) {
		var obj = {};
		for (var i = 0; i < params.length; i++) {
			var ofield = p + "_" + params[i] + "_" + field;
			if (typeof db_kcp[ofield] == "undefined") {
				obj = null;
				break;
			}
			obj[params[i]] = db_kcp[ofield];
			
		}
		if (obj != null) {
			var node_a = parseInt(field);
			if (node_a > kcp_node_max) {
				kcp_node_max = node_a;
			}
			obj["kcp_node"] = field;
			kcp_confs[field] = obj;
		}
	}
	return kcp_confs;
}
//----------------------------KCP代码部分END--------------------------------------//
//------------------------------自定义host代码部分BEGIN-----------------------------//
function gethostmax(){
	$.ajax({
		type: "GET",
		url: "/_api/merlinclash_host",
		dataType: "json",
		async: false,
		success: function(data) {
			db_host = data.result[0];
			gethostConfigs();
			//after table generated and value filled, set default value for first line_image1
		}
	});
}
function refresh_host_table(q) {
	$.ajax({
		type: "GET",
		url: "/_api/merlinclash_host",
		dataType: "json",
		async: false,
		success: function(data) {
			db_host = data.result[0];
			refresh_host_html();
				
			//write dynamic table value
			for (var i = 1; i < host_node_max + 1; i++) {
				$('#merlinclash_host_hostname_' + i).val(db_host["merlinclash_host_hostname_" + i]);
				$('#merlinclash_host_address_' + i).val(db_host["merlinclash_host_address_" + i]);

			}
			//after table generated and value filled, set default value for first line_image1
		}
	});
}
function addTrhost() {
	if(!$.trim($('#merlinclash_host_hostname').val())){
		alert("hostname不能为空！");
		return false;
	}
	if(!$.trim($('#merlinclash_host_address').val())){
		alert("地址不能为空！");
		return false;
	}
	var host = {};
	var p = "merlinclash_host";
	host_node_max += 1;
	var params = ["hostname", "address"];
	for (var i = 0; i < params.length; i++) {
		host[p + "_" + params[i] + "_" + host_node_max] = $('#' + p + "_" + params[i]).val();
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": host};
	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		error: function(xhr) {
			console.log("error in posting config of table");
		},
		success: function(response) {
			refresh_host_table();
			E("merlinclash_host_hostname").value = "";
			E("merlinclash_host_address").value = "";
		}
	});
	hostpid = 0;
}
//20200707
function saveTrhost(o) {
	var id = $(o).attr("id"); 
	var ids = id.split("_");
	var p = "merlinclash_nhost";
	var q = "merlinclash_host";
	id = ids[ids.length - 1];
	var host = {};
	var params = ["hostname", "address"];


	for (var i = 0; i < params.length; i++) {
		$("#host_tr_" + id + " input[name='"+ p +"_" + params[i] + "_" + id+ "']").each(function () {
			host[q + "_" + params[i] + "_" + id] = $("#merlinclash_host_"+ params[i] + "_" +id).val();
		//	alert($("#merlinclash_pgnodes_"+ params[i] + "_" +id).val());
		//	alert(pgnodes[q + "_" + params[i] + "_" + id]);
		});
	}
	//alert(pgnodes[q + "_" + params[1] + "_" + id]);
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": host};

	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {		
			refresh_host_table();
			refreshpage();
		}
	});	
}
function delTrhost(o) {
	var id = $(o).attr("id");
	var ids = id.split("_");
	var p = "merlinclash_host";
	id = ids[ids.length - 1];
	var host = {};
	var params = ["hostname", "address"];
	for (var i = 0; i < params.length; i++) {
		db_merlinclash[p + "_" + params[i] + "_" + id] = host[p + "_" + params[i] + "_" + id] = "";
	}
	var id = parseInt(Math.random() * 100000000);
	var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": host};

	$.ajax({
		type: "POST",
		cache:false,
		url: "/_api/",
		data: JSON.stringify(postData),
		dataType: "json",
		success: function(response) {		           
			refresh_host_table();
			//refreshpage();
		}
	});
}
//-----------------------删除所有自定规则 开始----------------------//
function delallaclconfigs() {
		getaclconfigsmax();
		if(acl_node_max != "undefined"){
			var p = "merlinclash_acl";
			acl_node_del = acl_node_max;
			var acls = {};
			var params = ["type", "content", "lianjie"];
			for (var j=acl_node_del; j>0; j--) {
				for (var i = 0; i < params.length; i++) {
					acls[p + "_" + params[i] + "_" + j] = "";		
				}
			}
			acl_node_max = 0;
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": acls};

			$.ajax({
				type: "POST",
				cache:false,
				url: "/_api/",
				data: JSON.stringify(postData),
				dataType: "json",
				success: function(response) {		           
					refresh_acl_table();
					refreshpage();
				}
			});	
		}
			
}
function getaclconfigsmax(){
	$.ajax({
		type: "GET",
		url: "/_api/merlinclash_acl",
		dataType: "json",
		async: false,
		success: function(data) {
			db_acls = data.result[0];
			getACLConfigs();
			//after table generated and value filled, set default value for first line_image1
		}
	});
}
//-----------------------删除所有自定规则 结束----------------------//

//-----------------------删除所有节点指定 开始----------------------//
function delallhost() {
		gethostmax();
		if(host_node_max != "undefined"){
			var p = "merlinclash_host";
			host_node_del = host_node_max;
			var host = {};
			var params = ["hostname", "address"];
			for (var j=host_node_del; j>0; j--) {
				for (var i = 0; i < params.length; i++) {
					host[p + "_" + params[i] + "_" + j] = "";		
				}
			}
			host_node_max = 0;
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": host};

			$.ajax({
				type: "POST",
				cache:false,
				url: "/_api/",
				data: JSON.stringify(postData),
				dataType: "json",
				success: function(response) {		           
					refresh_host_table();
					refreshpage();
				}
			});	
		}
			
}
//-----------------------删除所有节点指定 结束----------------------//
function apply_delallhost() {
		gethostmax();
		if(pgnodes_node_max != null){
			var p = "merlinclash_host";
			host_node_del = host_node_max;
			//alert(pgnodes_node_del);
			var host = {};
			var params = ["hostname", "address"];
			for (var j=host_node_del; j>0; j--) {
				for (var i = 0; i < params.length; i++) {
					db_merlinclash["merlinclash_host_" + params[i] + "_" + j] = host["merlinclash_host_" + params[i] + "_" + j] = "";
					db_merlinclash["merlinclash_nhost_" + params[i] + "_" + j] = host["merlinclash_nhost_" + params[i] + "_" + j] = "";
					//alert("a"+pgnodes[p + "_" + params[i] + "_" + j]);		
				}
			}
			host_node_max = 0;
			var id = parseInt(Math.random() * 100000000);
			var postData = {"id": id, "method": "dummy_script.sh", "params":[], "fields": host};
			$.ajax({
				type: "POST",
				cache:false,
				url: "/_api/",
				data: JSON.stringify(postData),
				dataType: "json",
				success: function(response) {
					//alert("b"+pgnodes["merlinclash_pgnodes_proxygroup_1"]);
					//alert("c"+pgnodes["merlinclash_npgnodes_proxygroup_1"]);
					refresh_host_table();
					//alert('检测到配置文件变化，将清空前配置节点指定内容');
				}
			});	
		}
			
}
function refresh_host_html() {
	host_confs = gethostConfigs();
	var code2 = '';
	//table th
	code2 += '<table width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="FormTable_table host_lists" style="margin:-1px 0px 0px 0px;">'
		code2 += '<tr>'
			code2 += '<th width="40%" style="text-align: center; vertical-align: middle;">hostname</th>'
			code2 += '<th width="40%" style="text-align: center; vertical-align: middle;">地址</th>'
			code2 += '<th width="20%">操作</th>'
		code2 += '</tr>'
	code2 += '</table>'
	// table input area
	code2 += '<table id="HOST_table" width="750px" border="0" align="center" cellpadding="4" cellspacing="0" class="list_table host_lists" style="margin:-1px 0px 0px 0px;">'
		code2 += '<tr>'
	//hostname
			code2 += '<td width="40%">'
				code2 += '<input type="text" id="merlinclash_host_hostname" class="input_ss_table" style="width:80%;text-align:center;" placeholder="" />'
			code2 += '</td>'
	//地址
			code2 += '<td width="40%">'
				code2 += '<input type="text" id="merlinclash_host_address" class="input_ss_table" style="width:90%;text-align:center;" placeholder="" />'
			code2 += '</td>'	
	// add/delete 按钮
			code2 += '<td width="20%">'
				code2 += '<input style="margin-left: 6px;margin: -2px 0px -4px -2px;" type="button" class="add_btn" onclick="addTrhost()" value="" />'
			code2 += '</td>'
		code2 += '</tr>'
	// kcp table data area
	for (var field in host_confs) {
		var hc = host_confs[field];		
		code2 += '<tr id="host_tr_' + hc["host_node"] + '">';
			code2 += '<td width="40%">'
				code2 += '<input type="text" id="merlinclash_host_hostname_' + hc["host_node"] +' "name="merlinclash_host_hostname_' + hc["host_node"] +'" class="input_option_2" style="width:80%;text-align:center;" value="' + hc["hostname"] +'" />'
			code2 += '</td>';
			code2 += '<td width="40%">'
				code2 += '<input type="text" id="merlinclash_host_address_' + hc["host_node"] +' "name="merlinclash_host_address_' + hc["host_node"] +'" class="input_option_2" style="width:90%;text-align:center;" value="' + hc["address"] +'" />'
			code2 += '</td>';
			code2 += '<td width="20%">';
				code2 += '<input style="margin: 0px 0px -4px -2px;" id="host_nodes_' + hc["host_node"] + '" class="edit_btn" type="button" onclick="saveTrhost(this);" value="">'
				code2 += ' '
				code2 += '<input style="margin: 0px 0px -4px -2px;" id="host_noded_' + hc["host_node"] + '" class="remove_btn" type="button" onclick="delTrhost(this);" value="">'
				//code2 += '<input style="width:60px" id="pgnodes_nodes_' + pc["pgnodes_node"] + '" class="ss_btn" type="button" onclick="saveTrpgnodes(this);" value="保存">'
				//code2 += ' '
				//code2 += '<input style="width:60px" id="pgnodes_noded_' + pc["pgnodes_node"] + '" class="ss_btn" type="button" onclick="delTrpgnodes(this);" value="删除">'
			code2 += '</td>';
		code2 += '</tr>';
	//	nproxygroup_select_get(hc["pgnodes_node"]);
	//	nproxies_select_get(hc["pgnodes_node"]);
	}
	code2 += '</table>';

	$(".host_lists").remove();
	$('#merlinclash_host_table').after(code2);

}
function gethostConfigs() {
	var dicthost = {};
	host_node_max = 0;
	for (var field in db_host) {
		hostnames = field.split("_");
		
		dicthost[hostnames[hostnames.length - 1]] = 'ok';
	}
	host_confs = {};
	var p = "merlinclash_host";
	var params = ["hostname", "address"];
	for (var field in dicthost) {
		var obj = {};
		for (var i = 0; i < params.length; i++) {
			var ofield = p + "_" + params[i] + "_" + field;
			if (typeof db_host[ofield] == "undefined") {
				obj = null;
				break;
			}
			obj[params[i]] = db_host[ofield];
			
		}
		if (obj != null) {
			var node_a = parseInt(field);
			if (node_a > host_node_max) {
				host_node_max = node_a;
			}
			obj["host_node"] = field;
			host_confs[field] = obj;
		}
	}
	return host_confs;
}
//------------------------------自定义host代码部分END-------------------------------//
</script>
<script>
	// IP 检查
	var IP = {
		get: (url, type) =>
			fetch(url, { method: 'GET' }).then((resp) => {
				if (type === 'text')
					return Promise.all([resp.ok, resp.status, resp.text(), resp.headers]);
				else {
					return Promise.all([resp.ok, resp.status, resp.json(), resp.headers]);
				}
			}).then(([ok, status, data, headers]) => {
				if (ok) {
					let json = {
						ok,
						status,
						data,
						headers
					}
					return json;
				} else {
					throw new Error(JSON.stringify(json.error));
				}
			}).catch(error => {
				throw error;
			}),
		parseIPIpip: (ip, elID) => {
			IP.get(`https://api.skk.moe/network/parseIp/ipip/v3/${ip}`, 'json')
				.then(resp => {
					let x = '';
					for (let i of resp.data) {
						x += (i !== '') ? `${i} ` : '';
					}
	
					E(elID).innerHTML = x;
					//E(elID).innerHTML = `${resp.data.country} ${resp.data.regionName} ${resp.data.city} ${resp.data.isp}`;
				})
		},
		getIpipnetIP: () => {
			IP.get(`https://myip.ipip.net?${+(new Date)}`, 'text')
				.then(resp => E('ip-ipipnet').innerHTML = resp.data.replace('当前 IP：', '').replace('来自于：', ''));
		},
		getSohuIP: (data) => {
			E('ip-sohu').innerHTML = returnCitySN.cip;
			IP.parseIPIpip(returnCitySN.cip, 'ip-sohu-ipip');
		},
		getIpsbIP: (data) => {
			E('ip-ipsb').innerHTML = data.address;
			E('ip-ipsb-geo').innerHTML = `${data.country} ${data.province} ${data.city} ${data.isp.name}`
		},
		getIpApiIP: () => {
			IP.get(`https://api.ipify.org/?format=json&id=${+(new Date)}`, 'json')
				.then(resp => {
					E('ip-ipapi').innerHTML = resp.data.ip;
					return resp.data.ip;
				})
				.then(ip => {
					IP.parseIPIpip(ip, 'ip-ipapi-geo');
				})
		},
	};
	// 网站访问检查
	var HTTP = {
		checker: (domain, cbElID) => {
			let img = new Image;
			let timeout = setTimeout(() => {
				img.onerror = img.onload = null;
				img = null;
				E(cbElID).innerHTML = '<span style="color:#F00">连接超时</span>'
			}, 5000);
	
			img.onerror = () => {
				clearTimeout(timeout);
				E(cbElID).innerHTML = '<span style="color:#F00">无法访问</span>'
			}
	
			img.onload = () => {
				clearTimeout(timeout);
				E(cbElID).innerHTML = '<span style="color:#6C0">连接正常</span>'
			}
	
			img.src = `https://${domain}/favicon.ico?${+(new Date)}`
		},
		runcheck: () => {
			HTTP.checker('www.baidu.com', 'http-baidu');
			//HTTP.checker('s1.music.126.net/style', 'http-163');
			HTTP.checker('github.com', 'http-github');
			HTTP.checker('www.youtube.com', 'http-youtube');
		}
	};
	var merlinclash = {
		checkIP: () => {	
			IP.getIpipnetIP();
			//IP.getSohuIP();
			IP.getIpApiIP();
			HTTP.runcheck();
			setTimeout("merlinclash.checkIP();", 20000);
		},
	}
</script>
</head>
<body onload="init();">
<div id="TopBanner"></div>
<div id="Loading" class="popup_bg"></div>
<div id="LoadingBar" class="popup_bar_bg_ks" style="z-index: 200;" >
<table cellpadding="5" cellspacing="0" id="loadingBarBlock" class="loadingBarBlock" align="center">
	<tr>
		<td height="100">
		<div id="loading_block3" style="margin:10px auto;margin-left:10px;width:85%; font-size:12pt;"></div>
		<div id="loading_block2" style="margin:10px auto;width:95%;"></div>
		<div id="log_content2" style="margin-left:15px;margin-right:15px;margin-top:10px;overflow:hidden">
			<textarea cols="50" rows="36" wrap="off" readonly="readonly" id="log_content3" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false" style="border:1px solid #000;width:99%; font-family:'Lucida Console'; font-size:11px;background:transparent;color:#FFFFFF;outline: none;padding-left:3px;padding-right:22px;overflow-x:hidden"></textarea>
		</div>
		<div id="ok_button" class="apply_gen" style="background: #000;display: none;">
			<input id="ok_button1" class="button_gen" type="button" onclick="hideMCLoadingBar()" value="确定">
		</div>
		</td>
	</tr>
</table>
</div>
<table class="content" align="center" cellpadding="0" cellspacing="0">
	<tr>
		<td width="17">&nbsp;</td>
		<td valign="top" width="202">
			<div id="mainMenu"></div>
			<div id="subMenu"></div>
		</td>
		<td valign="top">
			<div id="tabMenu" class="submenuBlock"></div>
			<table width="98%" border="0" align="left" cellpadding="0" cellspacing="0" style="display: block;">
				<tr>
					<td align="left" valign="top">
						<div>
							<table width="760px" border="0" cellpadding="5" cellspacing="0" bordercolor="#6b8fa3" class="FormTitle" id="FormTitle">
								<tr>
									<td bgcolor="#4D595D" colspan="3" valign="top">
										<div>&nbsp;</div>
										<div class="formfonttitle">Merlin Clash</div>
										<div style="float:right; width:15px; height:25px;margin-top:-20px">
											<img id="return_btn" onclick="reload_Soft_Center();" align="right" style="cursor:pointer;position:absolute;margin-left:-30px;margin-top:-25px;" title="返回软件中心" src="/images/backprev.png" onMouseOver="this.src='/images/backprevclick.png'" onMouseOut="this.src='/images/backprev.png'"></img>
										</div>
										<div style="margin:10px 0 10px 5px;" class="splitLine"></div>
										<div class="SimpleNote" id="head_illustrate"><i></i>
											<p><a href="https://github.com/Dreamacro/clash" target="_blank"><em><u>Clash</u></em></a>是一个基于规则的代理程序，支持<a href="https://github.com/shadowsocks/shadowsocks-libev" target="_blank"><em><u>SS</u></em></a>、<a href="https://github.com/shadowsocksrr/shadowsocksr-libev" target="_blank"><em><u>SSR</u></em></a>、<a href="https://github.com/v2ray/v2ray-core" target="_blank"><em><u>V2Ray</u></em></a>、<a href="https://github.com/trojan-gfw/trojan" target="_blank"><em><u>Trojan</u></em></a>等方式科学上网。</p>
											<p style="color:#FC0">注意：1.Clash需要专用订阅或配置文件才可以使用，如果您的机场没提供订阅，可以使用插件内置的2种【<a style="cursor:pointer" onclick="dingyue()" href="javascript:void(0);"><em><u>规则转换</u></em></a>】，</p>
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;或者使用【<a style="cursor:pointer" onclick="dingyue()" href="javascript:void(0);"><em><u>SubConverter本地转换</u></em></a>】。
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.本插件不能与【<a href="./Module_shadowsocks.asp" target="_blank"><em><u>科学上网</u></em></a>】同时运行。开启后如果Aria2/AiCloud无法外网访问，请设置<a href="./Advanced_VirtualServer_Content.asp" target="_blank"><em><u>端口转发</u></em></a>。</p>
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3.使用延迟最低(Url-Test)&nbsp;|&nbsp;故障切换(Fallback)&nbsp;|&nbsp;负载均衡(Load-Balance)等自动策略组前，请确认您的机场允许频繁TCPing，</p>
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;否则您的帐号可能会被限制。</p>
											<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.常用clash二进制【<a href="https://github.com/flyhigherpi/merlinclash_clash_binary/tree/master/clash_binary_history" target="_blank"><em><u>文件下载</u></em></a>】。</p>
										</div>
										<!-- this is the popup area for process status -->
										<div id="detail_status"  class="content_status" style="box-shadow: 3px 3px 10px #000;margin-top: -20px;display: none;">
											<div class="user_title">【Merlin Clash】状态检测</div>
											<div style="margin-left:15px"><i>&nbsp;&nbsp;目前本功能支持Merlin Clash相关进程状态和iptables表状态检测。</i></div>
											<div style="margin: 10px 10px 10px 10px;width:98%;text-align:center;overflow:hidden">
												<textarea cols="63" rows="36" wrap="off" id="proc_status" style="width:98%;padding-left:13px;padding-right:33px;border:0px solid #222;font-family:'Lucida Console'; font-size:11px;background: transparent;color:#FFFFFF;outline: none;overflow-x:hidden;" autocomplete="off" autocorrect="off" autocapitalize="off" spellcheck="false"></textarea>
											</div>
											<div style="margin-top:5px;padding-bottom:10px;width:100%;text-align:center;">
												<input class="button_gen" type="button" onclick="close_proc_status();" value="返回主界面">
											</div>
										</div>
										<!-- this is the popup area for foreign status -->
										<div id="merlinclash_switch_show" style="margin:-1px 0px 0px 0px;">
											<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
												<thead>
												<tr>
													<td colspan="2">开关</td>
												</tr>
												</thead>
												<tr>
												<th id="merlinclash_switch">Merlin Clash开关</th>
													<td colspan="2">
														<div class="switch_field" style="display:table-cell;float: left;">
															<label for="merlinclash_enable">
																<input id="merlinclash_enable" class="switch" type="checkbox" style="display: none;">
																<div class="switch_container" >
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
														<div id="merlinclash_version_show" style="display:table-cell;float: left;position: absolute;margin-left:70px;padding: 5.5px 0px;">
															<a class="hintstyle">
																<i>当前版本：</i>
															</a>
														</div>
														<div style="display:table-cell;float: left;margin-left:250px;position: absolute;padding: 5.5px 0px;">
															<a type="button" class="ss_btn" style="cursor:pointer" onclick="get_proc_status()" href="javascript:void(0);">详细状态</a>
														</div>
														<div id="update_button" style="display:table-cell;float: left;position: absolute;margin-left:320px;padding: 5.5px 0px;">
															<a id="updateBtn" type="button" class="ss_btn" style="cursor:pointer" onclick="update_mc()">版本检查</a>
														</div>
													</td>
												</tr>
											</table>
										</div>
										<div id="tablets">
											<table style="margin:10px 0px 0px 0px;border-collapse:collapse" width="100%" height="37px">
												<tr>
													<td cellpadding="0" cellspacing="0" style="padding:0" border="1" bordercolor="#222">
														<input id="show_btn0" class="show-btn0" width="11%" style="cursor:pointer" type="button" value="首页功能" />
														<input id="show_btn1" class="show-btn1" width="11%" style="cursor:pointer" type="button" value="配置文件" />														
														<input id="show_btn2" class="show-btn2" width="11%" style="cursor:pointer" type="button" value="自定规则" />
														<input id="show_btn9" class="show-btn9" width="11%" style="cursor:pointer" type="button" value="设备绕行" />
														<input id="show_btn3" class="show-btn3" width="11%" style="cursor:pointer" type="button" value="高级模式" />
                                                        <input id="show_btn8" class="show-btn8" width="11%" style="cursor:pointer" type="button" value="云村解锁" />
														<input id="show_btn4" class="show-btn4" width="11%" style="cursor:pointer" type="button" value="附加功能" />
														<input id="show_btn7" class="show-btn7" width="11%" style="cursor:pointer" type="button" value="节点恢复" />
														<input id="show_btn5" class="show-btn5" width="11%" style="cursor:pointer" type="button" value="操作日志" />
														<input id="show_btn6" class="show-btn6" width="11%" style="cursor:pointer" type="button" value="当前配置" />
														<input id="show_btn10" class="show-btn10" width="11%" style="cursor:pointer" type="button" value="DC用户" />
                                                    </td>
												</tr>
											</table>
										</div>
										<!--首页功能区-->
										<div id="tablet_0" style="display: none;">
											<div id="merlinclash-content-overview">												
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
													<thead>
														<tr>
															<td colspan="2">状态检查</td>
														</tr>
														</thead>
													<tr id="clash_state">
														<th>插件运行状态</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	
																		<span id="clash_state2">Clash 进程状态 - Waiting...</span>
																		<br/>
																		<span id="clash_state3">Clash 看门狗进程状态 - Waiting...</span>
																	
																</div>
															</td>
														</tr>
												</table>
												<div id="merlinclash-ip" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<tr id="ip_state">
														<th>连通性检查</th>
															<td>
																<div style="padding-right: 20px;">
																	<div style="display: flex;">
																		<div style="width: 61.8%">IP 地址检查</div>
																		<div style="width: 40%">网站访问检查</div>
																	</div>
																</div>
																<div>
																	<div style="display: flex;">
																		<div style="width: 61.8%">
																			<p><span class="ip-title">IPIP&nbsp;&nbsp;国内</span>:&nbsp;<span id="ip-ipipnet"></span></p>
																			<p><span class="ip-title">IPAPI&nbsp;海外</span>:&nbsp;<span id="ip-ipapi"></span>&nbsp;<span id="ip-ipapi-geo"></span></p>
																		</div>
																		<div style="width: 40%">
																			<p><span class="ip-title">百度搜索</span>&nbsp;:&nbsp;<span id="http-baidu"></span></p>
																			<p><span class="ip-title">GitHub</span>&nbsp;:&nbsp;<span id="http-github"></span></p>
																			<p><span class="ip-title">YouTube</span>&nbsp;:&nbsp;<span id="http-youtube"></span></p>
																		</div>
																	</div>
																	<p><span style="float: right">（只检测您浏览器当前状况）</p>
																	<p><span style="float: right">Powered by <a href="https://ip.skk.moe" target="_blank">ip.skk.moe</a></span></p>
																</div>
															</td>
													</tr>
												</table>
												</div>
												
												<div id="merlinclash-yamls" style="margin:-1px 0px 0px 0px;">
													<form name="form1">
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
														<thead>
															<tr>
																<td colspan="2">配置文件</td>
															</tr>
															</thead>
														<tr id="yamlselect">
															<th>配置文件选择</th>
																<td colspan="2">
																	<!--<input type="hidden" value="${stu.merlinclash_yamlsel}" id="yamlfile" />-->
																	<select id="merlinclash_yamlsel"  name="yamlsel" dataType="Notnull" msg="配置文件不能为空!" class="input_option" ></select>
																</td>
														</tr>
													</table>
													</form>
												</div>
												
												<div id="merlinclash-dns" style="margin:-1px 0px 0px 0px;">
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
														<thead>
															<tr>
																<td colspan="2">DNS方案</td>
															</tr>
															</thead>
														<tr id="dns_plan">
															<th><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(1)">DNS方案</a></th>
																<td colspan="2">
																	<label for="merlinclash_dnsplan">
																		<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="rh" checked="checked">默认:Redir-Host
																		<!--<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="rh">Redir-Host-->
																		<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="rhp">Redir-Host+
																		<input id="merlinclash_dnsplan" type="radio" name="dnsplan" value="fi">Fake-ip
																	</label>	
																	<p style="color:#FC0">&nbsp;</p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;1.默认为Reidr-Host，国内解析优先，但DNS可能被污染。</p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;2.Reidr-Host+，代理路由自身DNS请求，确保DNS无污染。</p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;3.Fake-ip，拒绝DNS污染，无法通过ping获得真实IP。<a href="https://github.com/Fndroid/clash_for_windows_pkg/wiki/DNS%E6%B1%A1%E6%9F%93%E5%AF%B9Clash%EF%BC%88for-Windows%EF%BC%89%E7%9A%84%E5%BD%B1%E5%93%8D" target="_blank"><em><u>相关说明</u></em></a></p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;4.各模式DNS可通过附加功能的【<a style="cursor:pointer" onclick="dnsplan()" href="javascript:void(0);"><em><u>内置DNS方案</em></u></a>】自行设置。</p>
																	<p style="color:#FC0">&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;(与KoolProxy并未完美兼容，切忌在Fake-ip模式下升级路由固件)。</p>
																</td>
														</tr>
													</table>
												</div>
												
												
											
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
														<thead>
														<tr>
															<td colspan="2">Clash管理面板</td>
														</tr>
														</thead>
														<tr id="clash_dashboard">
															<th>面板信息</th>
																<td>
																	<div style="display:table-cell;float: left;margin-left:0px;">																			
																		<span id="dashboard_state2">管理面板</span>&nbsp;|&nbsp;<span id="dashboard_state4">面板密码</span>
																	</div>
																</td>
														</tr>
														<tr>
														<th id="btn-open-clash-dashboard" class="btn btn-primary">访问 Clash 管理面板</th>
															<td colspan="2">
																<div class="merlinclash-btn-container">
																	<!--<a href="http://yacd.haishan.me/" target="_blank" id="yacd" ><button type="button" class="ss-btn">访问 YACD-Clash 面板</button></a>
																	<a href="http://clash.razord.top/" target="_blank" id="yacd" ><button type="button" class="ss-btn">访问 RAZORD-Clash 面板</button></a>-->
																	<a type="button" style="vertical-align: middle; cursor:pointer;" id="yacd" class="ss_btn" href="http://yacd.haishan.me/" target="_blank" >访问 YACD-Clash 面板</a>
																	<a type="button" style="vertical-align: middle; cursor:pointer;" class="ss_btn" id="razord" href="http://clash.razord.top/" target="_blank">访问 RAZORD-Clash 面板</a>
																	
																	<p style="margin-top: 8px">只有在 Clash 正在运行的时候才可以访问 Clash 管理面板</p>
																</div>
															</td>
														</tr>
														<tr>
															<th id="btn-quicklyrestart" class="btn btn-primary">快速重启</th>
																<td colspan="2">
																	<div class="merlinclash-btn-quicklyrestart">																	
																		<a type="button" style="vertical-align: middle; cursor:pointer;" class="ss_btn" id="quicklyrestart" onclick="quickly_restart()">&nbsp;&nbsp;快速重启&nbsp;&nbsp;</a><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(7)"><em style="color: gold;">【功能说明】</em></a>														
																	</div>
																</td>
														</tr>
														<tr id="clash_restart_job_tr">
															<th>
																<label >定时重启</label>
															</th>
															<td>
																<select name="select_clash_restart" id="merlinclash_select_clash_restart" onChange="show_job()"  class="input_option" style="margin:-1 0 0 10px;">
																	<option value="1" selected>关闭</option>
																	<option value="5">每隔</option>
																	<option value="2">每天</option>
																	<option value="3">每周</option>
																	<option value="4">每月</option>
																</select>
																<select name="select_clash_restart_day" id="merlinclash_select_clash_restart_day" class="input_option" ></select>
																<select name="select_clash_restart_week" id="merlinclash_select_clash_restart_week" class="input_option" ></select>
																<select name="select_clash_restart_hour"  id="merlinclash_select_clash_restart_hour" class="input_option" ></select>
																<select name="select_clash_restart_minute"  id="merlinclash_select_clash_restart_minute" class="input_option" ></select>
																<select name="select_clash_restart_minute_2"  id="merlinclash_select_clash_restart_minute_2" class="input_option" ></select>
																<input  type="button" id="merlinclash_select_clash_restart_save" class="ss_btn" style="vertical-align: middle; cursor:pointer;" onclick="clash_restart_save();" value="保存设置" />
															</td>
														</tr>
														
												</table>
											</div>
										</div>
										<!--配置文件-->
										<div id="tablet_1" style="display: none;">
											<div id="merlinclash-content-config" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
														<td colspan="2">导入Clash配置文件</td>
													</tr>
													</thead>
													<tr>
													<th id="btn-open-clash-dashboard" class="btn btn-primary">手动上传Clash配置文件&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(10)"><em style="color: gold;">【上传必看】</em></a></th>
													<td colspan="2">
														<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
															<input type="file" id="clashconfig" size="50" name="file"/>
															<span id="clashconfig_info" style="display:none;">完成</span>															
															<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashconfig-btn-upload" class="ss_btn" onclick="upload_clashconfig()" >上传配置文件</a>
														</div>
													</td>
													</tr>														
												</table>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">

													
													<thead>
													<tr>
														<td colspan="2">其他订阅转换Clash规则&nbsp;&nbsp;&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(6)"><em>【帮助】</em></td>
													</tr>
													</thead>
													<tr>
														<th><br>小白一键订阅助手
															<br>
															<br><em style="color: gold;">右侧文本框内填入订阅地址，点击开始转换</em>			
															<!--<br><em style="color: gold;">（使用内置常规/游戏规则，杜绝订阅泄漏）</em>-->														
														</th>
														<td >
															<div class="SimpleNote" style="display:table-cell;float: left;">
																<label for="merlinclash_links2">
																	<textarea id="merlinclash_links2" placeholder="&nbsp;&nbsp;&nbsp;请输入订阅连接（支持多个订阅地址，回车分行或用'|'隔开）" type="text" style="resize: none; color: #FFFFFF; height:100px; width:400px;background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;"></textarea>
																</label>
															</div>
															<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<!--<select id="merlinclash_localrulesel" style="width:180px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																	<option value="常规规则">常规规则</option>
																	<option value="游戏规则">游戏规则</option>																																						
																</select>-->
																<input onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="merlinclash_uploadrename2" maxlength="5" style="color: #FFFFFF; width: 305px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;重命名(5位数字/字母)">
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="get_online_yaml2(17)" href="javascript:void(0);">&nbsp;&nbsp;开始转换&nbsp;&nbsp;</a>
															</div>
														</td>
													</tr>
													<tr>
														<th><br>SubConverter本地转换
															<br>
															<br><em style="color: gold;">SS&nbsp;|&nbsp;SSR&nbsp;|&nbsp;V2ray订阅|&nbsp;Trojan订阅</em>
															<br><em style="color: gold;">内置Acl4ssr项目规则</em>	
															<br><em style="color: gold;">规则默认选项并非最优，还需自己摸索</em>																
														</th>
														<td >
															<div class="SimpleNote" style="display:table-cell;float: left;">
																<label for="merlinclash_links3">
																	<textarea id="merlinclash_links3" placeholder="&nbsp;&nbsp;&nbsp;请输入订阅连接（支持多个订阅地址，回车分行或用'|'隔开）" type="text" style="resize: none; color: #FFFFFF; height:100px; width:400px;background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;"></textarea>
																</label>
															</div>														
															<div class="SimpleNote" style="display:table-cell;float: left; width: 400px;">
																<label>emoji:</label>																
																<input id="merlinclash_subconverter_emoji" type="checkbox" name="subconverter_emoji" checked="checked">
																<label>启用udp:</label>																
																<input id="merlinclash_subconverter_udp" type="checkbox" name="subconverter_udp">
																<label>节点类型:</label>																
																<input id="merlinclash_subconverter_append_type" type="checkbox" name="subconverter_append_type">
																<label>节点排序:</label>																
																<input id="merlinclash_subconverter_sort" type="checkbox" name="subconverter_sort">
																<label>过滤非法节点:</label>																
																<input id="merlinclash_subconverter_fdn" type="checkbox" name="subconverter_fdn">
																<br>
																<label>Skip certificate verify:</label>																
																<input id="merlinclash_subconverter_scv" type="checkbox" name="subconverter_scv">
																<label>TCP Fast Open:</label>																
																<input id="merlinclash_subconverter_tfo" type="checkbox" name="subconverter_tfo">
															</div>
															<div class="SimpleNote" style="display:table-cell;float: left; width: 400px;">
																<p><label>包含节点：</label>
																	<input id="merlinclash_subconverter_include" style="color: #FFFFFF; width: 320px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;筛选包含关键字的节点名，支持正则">
																</p>
																<br>
																<p><label>排除节点：</label>
																	<input id="merlinclash_subconverter_exclude" style="color: #FFFFFF; width: 320px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;过滤包含关键字的节点名，支持正则">
																</p>		
															</div>
															<div class="SimpleNote" style="display:table-cell;float: left; height: 30px; line-height: 30px; ">
																<select id="merlinclash_clashtarget" style="width:75px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																	<option value="clash">clash新参数</option>
																	<option value="clashr">clashR新参数</option>						
																</select>
																<select id="merlinclash_acl4ssrsel" style="width:170px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																	<option value="MC_Common">Merlin Clash_常规规则</option>
																	<option value="MC_Area_Fallback">Merlin Clash_分区域故障转移</option>
																	<option value="MC_Area_Urltest">Merlin Clash_分区域自动测速</option>
																	<option value="MC_Area_NoAuto">Merlin Clash_分区域无自动测速</option>
																	<option value="MC_Area_Media">Merlin Clash_媒体与分区域自动测速</option>
																	<option value="MC_Area_Media_NoAuto">Merlin Clash_媒体与分区域无自动测速</option>
																	<option value="Online">Online默认版_分组比较全</option>
																	<option value="AdblockPlus">AdblockPlus_更多去广告</option>	
																	<option value="NoAuto">NoAuto_无自动测速</option>	
																	<option value="NoReject">NoReject_无广告拦截规则</option>	
																	<option value="Mini">Mini_精简版</option>	
																	<option value="Mini_AdblockPlus">Mini_AdblockPlus_精简版更多去广告</option>	
																	<option value="Mini_NoAuto">Mini_NoAuto_精简版无自动测速</option>
																	<option value="Mini_Fallback">Mini_Fallback_精简版带故障转移</option>	
																	<option value="Mini_MultiMode">Mini_MultiMode_精简版自动测速故障转移负载均衡</option>	
																	<option value="Full">Full全分组_重度用户使用</option>
																	<option value="Full_NoAuto">Full全分组_无自动测速</option>
																	<option value="Full_AdblockPlus">Full全分组_更多去广告</option>
																	<option value="Full_Netflix">Full全分组_奈飞全量</option>
																</select>
																<input onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="merlinclash_uploadrename4" maxlength="5" style="color: #FFFFFF; width: 50px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;重命名">
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="get_online_yaml3(16)" href="javascript:void(0);">&nbsp;&nbsp;开始转换&nbsp;&nbsp;</a>
															</div>
														</td>
													</tr>
													<tr>
														<th>
															<br><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(14)">Clash-Yaml配置下载</a>
															<br>
															<br><em style="color: gold;">Clash专用订阅&nbsp;|&nbsp;ACL4SSR等转换订阅</em>
														</th>
														<td >
															<div class="SimpleNote" style="display:table-cell;float: left;">
																<label for="merlinclash_links">
																	<textarea id="merlinclash_links" placeholder="&nbsp;&nbsp;&nbsp;请输入订阅连接（只支持单个订阅地址）" type="text" style="resize: none; color: #FFFFFF; height:100px; width:400px;background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;"></textarea>
																</label>
															</div>
															<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<input onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="merlinclash_uploadrename" maxlength="8" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;重命名,支持8位数字/字母">
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="get_online_yaml(2)" href="javascript:void(0);">&nbsp;&nbsp;Clash订阅&nbsp;&nbsp;</a>
																</div>
														</td>
													</tr>
												</table>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">导入【<a href=" ./Module_shadowsocks.asp" target="_blank"><em style="color:gold;">科学上网</em></a> 】节点</td>
														</tr>
														</thead>
													<tr id="ssconvert">
														<th>读取科学上网节点，转换为Clash规则</th>
															<td colspan="2">
																<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<input onkeyup="value=value.replace(/[^\w\.\/]/ig,'')" id="merlinclash_uploadrename3" maxlength="8" style="color: #FFFFFF; width: 305px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;转换文件命名,支持8位数字/字母">
																<label for="merlinclash_ssconvert_btn">
																	<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="ssconvert(6)" href="javascript:void(0);">&nbsp;&nbsp;一键转换&nbsp;&nbsp;</a>																
																</label>
															</div>
															</td>
													</tr>
												</table>
												<form name="form1">
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
														<thead>
															<tr>
																<td colspan="2">下载&nbsp;|&nbsp;删除配置文件</td>
															</tr>
															</thead>
														<tr id="delyamlselect">
															<th>配置文件选择&nbsp;&nbsp;<span id="clash_yamlsel">当前配置为：</span></th>
															<td colspan="2">
																<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<!--<input type="hidden" value="${stu.merlinclash_yamlsel}" id="yamlfile" />-->
																<select id="merlinclash_delyamlsel"  name="delyamlsel" dataType="Notnull" msg="配置文件不能为空!" class="input_option"></select>
																<a type="button" style="vertical-align: middle;" class="ss_btn" style="cursor:pointer" onclick="download_yaml_sel()" href="javascript:void(0);">&nbsp;&nbsp;下载配置&nbsp;&nbsp;</a>
																<a type="button" style="vertical-align: middle;" class="ss_btn" style="cursor:pointer" onclick="del_yaml_sel(0)" href="javascript:void(0);" >&nbsp;&nbsp;删除配置&nbsp;&nbsp;</a>
															</div>
															</td>
														</tr>
													</table>
												</form>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">定时订阅&nbsp;|&nbsp;<em style="color:gold;">不支持【手动上传】【科学上网节点导入】</em></td>
														</tr>
														</thead>
														<tr id="clash_regular_job_tr">
															<th>
																<label >定时订阅</label>
															</th>
															<td>
																<select name="select_regular_subscribe" id="merlinclash_select_regular_subscribe" onChange="show_job()"  class="input_option" style="margin:0 0 0 10px;">
																	<option value="1" selected>关闭</option>
																	<option value="5">每隔</option>
																	<option value="2">每天</option>
																	<option value="3">每周</option>
																	<option value="4">每月</option>
																</select>
																<select name="select_regular_day" id="merlinclash_select_regular_day" class="input_option" ></select>
																<select name="select_regular_week" id="merlinclash_select_regular_week" class="input_option" ></select>
																<select name="select_regular_hour"  id="merlinclash_select_regular_hour" class="input_option" ></select>
																<select name="select_regular_minute"  id="merlinclash_select_regular_minute" class="input_option" ></select>
																<select name="select_regular_minute_2"  id="merlinclash_select_regular_minute_2" class="input_option" ></select>
																<input  type="button" id="merlinclash_regular_save" class="ss_btn" style="vertical-align: middle; cursor:pointer;" onclick="regular_subscribe_save();" value="保存设置" />
															</td>
														</tr>
												</table>
											</div>				
										</div>
										<!--节点指定-->
										<!--<div id="tablet_7" style="display: none;">
											<div id="merlinclash_pgnodes_table">
											</div>												
											<div id="MEMO_note" style="margin:10px 0 0 5px">
											<div><i>&nbsp;&nbsp;1.该功能可以指定Clash策略组默认运行节点，仅对当前配置文件有效;</i></div>
											<div><i>&nbsp;&nbsp;2.请结合您的当前配置文件的【<em>策略组</em>】的可选项，按需设置。</i></div>
											<div><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;例：通过<a href="http://yacd.haishan.me/" target="_blank"><em>控制面板</em></a>中查看得知：【<em>策略组</em>】-【<em>总模式</em>】中有【<em>延迟最低</em>】【<em>节点一</em>】【<em>DIRECT</em>】三个选项，</i></div>
											<div><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;则在指定【<em>总模式</em>】的配置时，只能指定这三项，指定其他选项无效。</i></div>
											<div><i>&nbsp;</i></div>
											</div>				
										</div>-->
										<!--节点恢复-->
										<div id="tablet_7" style="display: none;">
											<div id="nodes_content" style="margin-top:0px; width:750px; height: 650px;">
												<textarea class="sbar" cols="63" rows="36" wrap="on" readonly="readonly" id="nodes_content1" style="margin: 0px; width: 709px; height: 645px; resize: none;"></textarea>
											</div>				
										</div>
										<!--自定规则-->
										<div id="tablet_2" style="display: none;">		
											<div id="merlinclash_acl_table">
											</div>
											<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
												<thead>
												<tr>
													<td colspan="2">备份/恢复</td>
												</tr>
												</thead>
												<tr>
													<th id="btn-open-clash-dashboard" class="btn btn-primary">备份自定义规则</th>
													<td colspan="2">
														<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashrestorerule-btn-download" class="ss_btn" onclick="down_clashrestorerule(1)" >导出自定义规则</a>
													</td>
												</tr>
												<tr>
												<th id="btn-open-clash-dashboard" class="btn btn-primary">恢复自定义规则</th>
												<td colspan="2">
													<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
														<input type="file" style="width: 200px;margin: 0,0,0,0px;" id="clashrestorerule" size="50" name="file"/>
														<span id="clashrestorerule_info" style="display:none;">完成</span>															
														<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashrestorerule-btn-upload" class="ss_btn" onclick="upload_clashrestorerule()" >恢复自定义规则</a>
													</div>
												</td>
												</tr>														
											</table>												
											<div id="ACL_note" style="margin:10px 0 0 5px">
										
											<div><i>&nbsp;&nbsp;<em>1.更换yaml配置文件后，请手动删除上一个配置文件的自定义规则！否则Clash可能无法正常启动。</em></i></div>
											<div><i>&nbsp;&nbsp;2.编辑规则有风险，请勿在没完全搞懂的情况下，胡乱尝试。</i></div>
											<div><i>&nbsp;&nbsp;3.如果您添加的规则不符合Clash的标准，进程会无法启动。请删除所有自定义规则，重新启动。</i></div>
											<div><i>&nbsp;&nbsp;4.如果新加规则和老规则冲突，则会按照新规则执行。</i></div>
											<div><i>&nbsp;&nbsp;5.【访问控制】写法示例：</i></div>
											<div><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;让某设备不过代理：类型：<em>SRC-IP-CIDR</em>，内容：<em>192.168.50.201/32</em>（IP必须有掩码位），连接方式：<em>DIRECT</em>（大写）</i></div>
											<div><i>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;禁止某端口联网：类型：<em>DST-PORT</em>，内容：<em>7777</em>（端口号），连接方式：<em>REJECT</em>（大写）</i></div>
											<div><i>&nbsp;&nbsp;6.更多说明请点击表头查看，或者参阅Clash的【<a href="https://lancellc.gitbook.io/clash/clash-config-file/rules" target="_blank"><em><u>开发文档</u></em></a>】。</i></div>
											<div><i>&nbsp;</i></div>
											</div>
										</div>
										<!--设备绕行-->
										<div id="tablet_9" style="display: none;">		
											<div id="merlinclash_device_table">
											</div>
											<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
												<thead>
												<tr>
													<td colspan="2">备份/恢复</td>
												</tr>
												</thead>
												<tr>
													<th id="btn-open-clash-dashboard" class="btn btn-primary">备份绕行设置</th>
													<td colspan="2">
														<a type="button" style="vertical-align: middle; cursor:pointer;" id="passdevice-btn-download" class="ss_btn" onclick="down_passdevice(1)" >导出绕行设置</a>
													</td>
												</tr>
												<tr>
												<th id="btn-open-clash-dashboard" class="btn btn-primary">恢复绕行设置</th>
												<td colspan="2">
													<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
														<input type="file" style="width: 200px;margin: 0,0,0,0px;" id="passdevice" size="50" name="file"/>
														<span id="passdevice_info" style="display:none;">完成</span>															
														<a type="button" style="vertical-align: middle; cursor:pointer;" id="passdevice-btn-upload" class="ss_btn" onclick="upload_passdevice()" >恢复绕行设置</a>
													</div>
												</td>
												</tr>														
											</table>												
											<div id="DEVICE_note" style="margin:10px 0 0 5px">
											<div><i>&nbsp;&nbsp;1.本功能通过iptables实现设备绕行，优先级高于Clash访问控制规则；<br>
											&nbsp;&nbsp;2.如果某些设备开启Clash无法正常联网，可尝试使用此功能；<br>
											&nbsp;&nbsp;3.请在【<a href="./Advanced_DHCP_Content.asp" target="_blank"><em><u>DHCP服务器</u></em></a>】中绑定您需要绕行的设备IP，否则可能会因设备IP改变导致规则失效。<br>
											&nbsp;&nbsp;4.两种绕行模式区别，请点击 <a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(15)"><em>绕行模式</em></a>表头查看。<br></i></div>
											<div><i>&nbsp;</i></div>
											</div>
										</div>
										<!--高级模式-->
										<div id="tablet_3" style="display: none;">
											<!--补丁更新-->
											<div id="merlinclash-patch" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">补丁更新</td>
														</tr>
														</thead>
														<tr>
															<th>安装补丁&nbsp;<span id="patch_version">【已装补丁版本】：</span></th>
																<td colspan="2">
																	<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																		<input type="file" id="clashpatch" size="50" name="file"/>
																		<span id="clashpatch_upload" style="display:none;">完成</span>															
																		<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashpatch-btn-upload" class="ss_btn" onclick="upload_clashpatch()" >上传补丁</a>
																		
																	</div>
																</td>		
														</tr>
												</table>
											</div>
											<!--启动检查延迟-->
											<div id="merlinclash-checkdalay" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">clash启动延迟 <a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(13)"><em>【说明】</em></a></td>
														</tr>
														</thead>
														<tr>
															<th>自定义延迟检查时间</th>
																<td colspan="2">
																	<div class="SimpleNote" id="head_illustrate">
																		<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'2')" id="merlinclash_check_delay_time" maxlength="2" style="color: #FFFFFF; width: 30px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" value="2" ><span>&nbsp;秒</span>															
																		<input id="merlinclash_check_delay_cbox" type="checkbox" name="merlinclash_check_delay_cbox">
																	</div>
																</td>		
														</tr>
												</table>
												</div>
											<!--测速延迟容差设定-->
											<div id="merlinclash-urltestTolerance" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">Tolerance容差值设定 <a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(16)"><em>【说明】</em></a></td>
														</tr>
														</thead>
														<tr>
															<th>自定义容差值</th>
																<td colspan="2">
																	<div class="SimpleNote" id="head_illustrate">
																		<select id="merlinclash_urltestTolerancesel" style="width:60px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																			<option value="100">100</option>
																			<option value="200">200</option>
																			<option value="300">300</option>
																			<option value="500">500</option>
																			<option value="1000">1000</option>						
																		</select>
																		<input id="merlinclash_urltestTolerance_cbox" type="checkbox" name="merlinclash_urltestTolerance_cbox">
																	</div>
																</td>		
														</tr>
												</table>
												</div>
											<!--IPV6-->
											<div id="merlinclash-ipv6" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">IPv6解析服务 -- 默认关闭</td>
														</tr>
														</thead>
													<tr id="dns_ipv6">
														<th>开启IPv6 DNS解析</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																<label for="merlinclash_ipv6switch">
																	<input id="merlinclash_ipv6switch" type="checkbox" name="ipv6" class="switch" style="display: none;">
																	<div class="switch_container" >
																		<div class="switch_bar"></div>
																		<div class="switch_circle transition_style">
																			<div></div>
																		</div>
																	</div>
																</label>
																
															</div>
															</td>
													</tr>
												</table>
											</div>	
											<div id="merlinclash-dashboard" style="margin:-1px 0px 0px 0px;">
											<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
												<thead>
												<tr>
													<td colspan="2">管理面板设定 -- <em style="color: gold;">【开启面板公网访问请设置复杂密码，并设置<a href="./Advanced_VirtualServer_Content.asp" target="_blank"><em>端口转发</em></a>】</em><a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(12)"><em>【教程】</em></a></td>
												</tr>
												</thead>
												<tr id="dashboard">	
												<th>开启管理面板公网访问</th>
												<td colspan="2">
													<div class="switch_field" style="display:table-cell;float: left;">
													<label for="merlinclash_dashboardswitch">
														<input id="merlinclash_dashboardswitch" type="checkbox" name="dashboard" class="switch" style="display: none;">
														<div class="switch_container" >
															<div class="switch_bar"></div>
															<div class="switch_circle transition_style">
																<div></div>
															</div>
														</div>
													</label>													
												</div>
												</td>
												</tr>												
												<tr>
													<th>管理面板密码</th>
														<td colspan="2">
															<div class="SimpleNote" id="head_illustrate">																	
																<input id="merlinclash_dashboard_secret" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">																
															</div>
														</td>		
												</tr>
																					
											</table>	
											</div>
											<div id="merlinclash-udp" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">UDP转发</td>
														</tr>
														</thead>
													<tr id="dns_plan">
														<th>UDP转发(实验性功能)&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(9)"><em style="color: gold;">【开启必看】</em></a></th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																<label for="merlinclash_udpr">
																	<input id="merlinclash_udpr" type="checkbox" name="udpr" class="switch" style="display: none;">
																	<div class="switch_container" >
																		<div class="switch_bar"></div>
																		<div class="switch_circle transition_style">
																			<div></div>
																		</div>
																	</div>
																</label>
																</div>
															</td>
													</tr>
												</table>
											</div>
											<!--自定义HOST-->
											<div id="merlinclash-content-config" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
													<thead>
														<tr>
															<td colspan="2">自定义HOST&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(11)"><em>【说明】</em>&nbsp;<a href="javascript:void(0);" onclick="download_host()"><em style="color: gold;">【导出host】</em></a><em style="color:gold;">|【开启编辑：<input id="merlinclash_hostedit_check" class="hostenableedit" type="checkbox" name="hostedit_check" >】</em></td>
														</tr>
														<script>
															$(function () {
																$(".hostenableedit").click(function () {
																	if (this.checked==true){
																		//alert("选中");
																		document.getElementById("merlinclash_host_content1").readOnly = false
	
																	}else{
																		//alert("不选中");
																		document.getElementById("merlinclash_host_content1").readOnly = true
																	}
																})
															})
														</script>
													</thead>
												</table>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
												<div id="merlinclash_host_content" style="margin-top:-1px;overflow:hidden;">
													<textarea rows="7" wrap="on" id="merlinclash_host_content1" style="margin: 0px; width: 709px; height: 300px; resize: none; " readonly="true"></textarea>
												</div>
												<tr>
													<th>上传HOST文件</th>
														<td colspan="2">
															<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																<input type="file" id="clashhost" size="50" name="file"/>
																<span id="clashhost_upload" style="display:none;">完成</span>															
																<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashhost-btn-upload" class="ss_btn" onclick="upload_clashhost()" >上传HOST文件</a>
																
															</div>
														</td>		
												</tr>
											</table>
												<!--<div id="merlinclash_host_table">
												</div>	-->								
											</div>
										
											<!--KCP加速-->
											<div id="merlinclash-content-config" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
														<td colspan="2">KCP加速 -- 需要服务器端支持  <a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(5)"><em>【帮助】</em></a> <a href="https://github.com/xtaci/kcptun/releases" target="_blank"><em style="color:gold;">【二进制下载】</em></a> </td>
													</tr>
													</thead>
													<tr>
														<th>KCP开关</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_kcpswitch">
																		<input id="merlinclash_kcpswitch" class="switch" type="checkbox" style="display: none;">
																		<div class="switch_container" >
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>																	
															</td>
														</tr>
												</table>
												<div id="merlinclash_kcp_table">
												</div>
											</div>	
											
										</div>
										<!--网易云解锁-->
										<div id="tablet_8" style="display: none;">
											<div id="merlinclash-unblockneteasemusic" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >																							
													<thead>
														<tr>
															<td colspan="2">设置 <a href="https://github.com/flyhigherpi/merlinclash_clash_binary/tree/master/UnblockNeteaseMusic_binary" target="_blank"><em style="color:gold;">【二进制下载】</em></a> </td>
														</tr>
														</thead>
														<tr>
															<th >本地解锁开关</th>
															<td colspan="2">
																<div class="switch_field" style="display:table-cell;float: left;">
																	<label for="merlinclash_unblockmusic_enable">
																		<input id="merlinclash_unblockmusic_enable" class="switch" type="checkbox" style="display: none;">
																		<div class="switch_container">
																			<div class="switch_bar"></div>
																			<div class="switch_circle transition_style">
																				<div></div>
																			</div>
																		</div>
																	</label>
																</div>
															</td>
														</tr>
														<tr>
															<th >插件版本</th>
															<td colspan="2"  id="merlinclash_unblockmusic_version">
															</td>
														</tr>
														<tr>
															<th >状态</th>
															<td colspan="2"  id="merlinclash_unblockmusic_status">
															</td>
														</tr>
														<tr id="merlinclash_unblockmusic_musicapptype_tr">
															<th>
																<label >音源</label>
															</th>
															<td>
																<div style="float:left; width:165px; height:25px">
																	<select id="merlinclash_unblockmusic_musicapptype" name="merlinclash_unblockmusic_musicapptype" style="width:164px;margin:0px 0px 0px 2px;" class="input_option">
																		<option value="default" >Default</option>
																		<option value="netease" >Netease</option>
																		<option value="qq" >QQ</option>
																		<option value="xiami" >Xiami</option>
																		<option value="baidu" >Baidu</option>
																		<option value="kugou" >Kugou</option>
																		<option value="kuwo" >Kuwo</option>
																		<option value="migu" >Migu</option>
																		<option value="joox" >Joox</option>
																	</select>
																</div>
															</td>
														</tr>
														<tr id="merlinclash_unblockmusic_endpoint_tr">
															<th>
																<label >Endpoint</label>
															</th>
															<td>
																<input type="text" id="merlinclash_unblockmusic_endpoint" name="merlinclash_unblockmusic_endpoint" class="input_ss_table" style="width:200px;" value="https://music.163.com" />
															</td>
														</tr>
														<tr id="merlinclash_unblockmusic_bestquality_tr">
															<th>
																<label >强制音质优先</label>
															</th>
															<td>
																<label for="merlinclash_unblockmusic_bestquality">
																	<input id="merlinclash_unblockmusic_bestquality" type="checkbox" name="unblockmusic_bestquality">
																</label>
															</td>
														</tr>
														<tr id="merlinclash_unblockmusic_platforms_numbers_tr">
															<th>
																<label >音源最大搜索结果(需0.2.5版本以上)</label>
															</th>
															<td>
																<input onkeyup="this.value=this.value.replace(/[^0-3]+/,'0')" maxlength="1" id="merlinclash_unblockmusic_platforms_numbers" class="input_ss_table" type="text" name="unblockmusic_platforms_numbers" value="0">
															</td>
														</tr>
														<tr id="cert_download_tr">
															<th>
																<label >证书下载</label>&nbsp;&nbsp;<a class="hintstyle" href="javascript:void(0);" onclick="openmcHint(8)"><em style="color: gold;">【证书相关】</em></a>																
															</th>
															<td>
																<input  type="button" id="merlinclash_unblockmusic_create_cert" class="ss_btn" style="vertical-align: middle; cursor:pointer;" onclick="createcert(9);" value="生成证书" />															
																<input  type="button" id="merlinclash_unblockmusic_download_cert" class="ss_btn" style="vertical-align: middle; cursor:pointer;" onclick="downloadcert();" value="下载证书" />
																
															</td>
														</tr>
														<tr id="unblockneteasemusic_restart_tr">
															<th>
																<label >重启进程</label>
															</th>
															<td>
																<input  type="button" id="merlinclash_unblockmusic_restart" class="ss_btn" style="width: 100px; vertical-align: middle; cursor:pointer;" onclick="unblock_restart();" value="重启解锁进程" />
															</td>
														</tr>	
														<tr id="unblockneteasemusic_restart_job_tr">
															<th>
																<label >网易云解锁定时重启</label>
															</th>
															<td>
																<select name="select_job" id="merlinclash_select_job" onChange="show_job()"  class="input_option" >
																	<option value="1" selected>关闭</option>
																	<option value="2">每天</option>
																	<option value="3">每周</option>
																	<option value="4">每月</option>
																</select>
																<select name="select_day" id="merlinclash_select_day" class="input_option" ></select>
																<select name="select_week" id="merlinclash_select_week" class="input_option" ></select>
																<select name="select_hour"  id="merlinclash_select_hour" class="input_option" ></select>
																<select name="select_minute"  id="merlinclash_select_minute" class="input_option" ></select>
																<input  type="button" id="merlinclash_job_save" class="ss_btn" style="vertical-align: middle; cursor:pointer;" onclick="unblock_restartjob_save();" value="保存设置" />
															</td>
														</tr>	
														<tr>
															<th>二进制上传</th>
																<td colspan="2">
																	<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																		<input type="file" id="unblockmusicbinary" size="50" name="file"/>
																		<span id="unblockmusicbinary_upload" style="display:none;">完成</span>															
																		<a type="button" style="vertical-align: middle; cursor:pointer;" id="unblockmusicbinary-btn-upload" class="ss_btn" onclick="upload_unblockmusicbinary()" >上传二进制</a>
																	</div>
																</td>		
														</tr>																			
												</table>
												<div id="UBM_note" style="margin:10px 0 0 5px"><i></i><em style="color: gold;">&nbsp;&nbsp;&nbsp;本模块采用 <a href="https://github.com/cnsilvan/UnblockNeteaseMusic" target="_blank"><em><u>Cnsilvan</em></u></a>编译的Golong版本的UnblockNeteaseMusic，实现解锁网易云音乐变灰歌曲，并通过iptabels实现透明代理解锁。<br>1.开启后，基本能实现设备联网即解锁，无需手动设置代理。<br>2.相对于之前解锁方式，本地解锁更加安全快速。<br>
												3.苹果设备经过测试均可正常解锁，如未成功解锁请按照证书<em>【安装说明】</em>操作。<br>4.如果发现解锁失败，请尝试：<br>&nbsp;&nbsp;&nbsp;a)重启解锁进程，查看设备是否解锁；<br>&nbsp;&nbsp;&nbsp;b)若重启仍无法解锁，可在APP/客户端里设置如下代理：<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;HTTP代理IP:<% nvram_get("lan_ipaddr"); %>，端口:5200<br>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;HTTPS代理IP:<% nvram_get("lan_ipaddr"); %>，端口:5300</div>
												
											</div>	
										</div>
										<!--附加功能-->
										<div id="tablet_4" style="display: none;">
											<div id="merlinclash-content-additional" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
														<td colspan="2">Clash 看门狗</td>
													</tr>
													</thead>
													<tr>
													<th>Clash 看门狗开关</th>
														<td colspan="2">
															<div class="switch_field" style="display:table-cell;float: left;">
																<label for="merlinclash_watchdog">
																	<input id="merlinclash_watchdog" class="switch" type="checkbox" style="display: none;">
																	<div class="switch_container" >
																		<div class="switch_bar"></div>
																		<div class="switch_circle transition_style">
																			<div></div>
																		</div>
																	</div>
																</label>
															</div>
															<div class="SimpleNote" id="head_illustrate">
																<p>进程守护工具，根据设定的时间，周期性检查 Clash 进程是否存在，如果 Clash 进程丢失则会自动重新拉起。</p>
																<p style="color:gold; margin-top: 8px">注意：Clash本身运行稳定，通常不必开启该功能。</p>
															</div>
														</td>
													</tr>
															<!--看门狗检查间隔-->
													<tr>
															<th>自定义检查时间</th>
																<td colspan="2">
																	<div class="SimpleNote" id="head_illustrate">
																		<input onkeyup="this.value=this.value.replace(/[^1-9]+/,'2')" id="merlinclash_watchdog_delay_time" maxlength="2" style="color: #FFFFFF; width: 30px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" value="2" ><span>&nbsp;分钟</span>															
																	</div>
																</td>		
														</tr>
												
												</table>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
                                                    	<td colspan="2">DlerCloud登陆选项</td>
													</tr>
													</thead>
													<tr>
													<th>显示开关 | 勾选则显示</th>
														<td colspan="2">
															<div class="switch_field" style="display:table-cell;float: left;">
															<label for="merlinclash_dlercloud_check">
																<input id="merlinclash_dlercloud_check" class="switch" type="checkbox" style="display: none;" name="dlercloud_check" onchange="dler_check()">
																<div class="switch_container" >
																	<div class="switch_bar"></div>
																	<div class="switch_circle transition_style">
																		<div></div>
																	</div>
																</div>
															</label>
														</div>
														</td>
														
													</tr>
												</table>
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_switch_table">
													<thead>
													<tr>
														<td colspan="2">更新管理</td>
													</tr>
													</thead>
													<tr>
													<th>GeoIP 数据库</th>
														<td colspan="2">
															<div class="SimpleNote" id="head_illustrate">
																<p>Clash 使用由 <a href="https://www.maxmind.com/" target="_blank"><u>MaxMind</u></a> 提供的 <a href="https://dev.maxmind.com/geoip/geoip2/geolite2/" target="_blank"><u>GeoLite2</u></a> IP 数据库解析 GeoIP 规则</p>
																<p style="color:#FC0">注：更新不会对比新旧版本号，重复点击会重复升级！（1个月左右更新一次即可）</p>
																<p>&nbsp;</p>
																<a type="button" class="ss_btn" style="cursor:pointer" onclick="geoip_update(5)">更新GeoIP数据库</a>
																<span id="geoip_updata_date">上次更新时间：</span>
																<!--<a type="button" class="ss_btn" style="cursor:pointer" href="https://download.maxmind.com/app/geoip_download?edition_id=GeoLite2-Country&license_key=oeEqpP5QI21N&suffix=tar.gz">点击下载GeoIP数据库</a>-->
															</div>
														</td>		
													</tr>
													<!--
													<tr>
														<th>clash二进制更新</th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">																	
																	<a type="button" class="ss_btn" style="cursor:pointer" onclick="clash_update(7)">更新clash二进制</a>
																	<span id="clash_update_date">&nbsp;&nbsp;上次更新时间：</span>
																</div>
															</td>		
													</tr>
													-->
													<tr>
														<th>clash二进制替换 --在线更换</th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">
																	<select id="merlinclash_clashbinarysel"  name="clashbinarysel" dataType="Notnull" class="input_option" ></select>
																	<a type="button" class="ss_btn" style="cursor:pointer" onclick="clash_getversion(10)">获取远程版本文件</a>		
																	<a type="button" class="ss_btn" style="cursor:pointer" onclick="clash_replace(11)">替换clash二进制</a>																	
																</div>
															</td>		
													</tr>
													<tr>
														<th>clash二进制替换 --本地替换</th>
															<td colspan="2">
																<div class="SimpleNote" style="display:table-cell;float: left; height: 110px; line-height: 110px; margin:-40px 0;">
																	<input type="file" id="clashbinary" size="50" name="file"/>
																	<span id="clashbinary_upload" style="display:none;">完成</span>															
																	<a type="button" style="vertical-align: middle; cursor:pointer;" id="clashbinary-btn-upload" class="ss_btn" onclick="upload_clashbinary()" >上传clash二进制</a>
																</div>
															</td>		
													</tr>
													<!--<tr>
														<th>内置【常规规则】更新</th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">																	
																	<a type="button" id="updatecomBtn" class="ss_btn" style="cursor:pointer" onclick="proxygroup_update(14)">&nbsp;&nbsp;更新常规规则&nbsp;&nbsp;</a>
																	<span id="proxygroup_version">&nbsp;&nbsp;当前版本：</span>
																	
																</div>
															</td>		
													</tr>
													<tr>
														<th>内置【游戏规则】更新</th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">																	
																	<a type="button" id="updategameBtn" class="ss_btn" style="cursor:pointer" onclick="proxygame_update(19)">&nbsp;&nbsp;更新游戏规则&nbsp;&nbsp;</a>
																	<span id="proxygame_version">&nbsp;&nbsp;当前版本：</span>
																	
																</div>
															</td>		
													</tr>-->
													<tr>
														<th>【subconverter规则】更新</th>
															<td colspan="2">
																<div class="SimpleNote" id="head_illustrate">																	
																	<a type="button" id="updatescBtn" class="ss_btn" style="cursor:pointer" onclick="sc_update(18)">&nbsp;&nbsp;更新S--C规则&nbsp;&nbsp;</a>
																	<span id="sc_version">&nbsp;&nbsp;当前版本：</span>
																	
																</div>
															</td>		
													</tr>
												</table>
																								
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_dnsfiles_table">
													<thead>
													<tr>
														<td colspan="2">内置DNS方案 -- <em style="color: gold;">【不懂勿动！编辑完成后点击“提交修改”保存配置，下次启动Merlin Clash时生效】|【开启编辑：<input id="merlinclash_dnsedit_check" class="barcodeSavePrint" type="checkbox" name="dnsedit_check" >】</em></td>
													</tr>
													<script>
														$(function () {
															$(".barcodeSavePrint").click(function () {
																if (this.checked==true){
																	//alert("选中");
																	document.getElementById("merlinclash_dns_edit_content1").readOnly = false

																}else{
																	//alert("不选中");
																	document.getElementById("merlinclash_dns_edit_content1").readOnly = true
																}
															})
														})
													</script>
													</thead>
													</table>
													<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" id="merlinclash_dnsfiles_content_table">
														<tr id="dns_plan_edit">
															<th>DNS内容编辑</th>
																<td colspan="2">
																	<label for="merlinclash_dnsplan_edit">
																		<input id="merlinclash_dnsplan_edit" type="radio" name="dnsplan_edit" value="redirhost" checked="checked">Redir-Host
																		<input id="merlinclash_dnsplan_edit" type="radio" name="dnsplan_edit" value="redirhostp">Redir-Host+
																		<input id="merlinclash_dnsplan_edit" type="radio" name="dnsplan_edit" value="fakeip">Fake-ip
																	</label>
																	<script>
																		$("[name='dnsplan_edit']").on("change",
																		function (e) {
																			console.log($(e.target).val());
																			var dns_tag=$(e.target).val();
																			//alert(dns_tag);
																			get_dnsyaml(dns_tag);
																		}
																		);
																	</script>	
																</td>
														</tr>
												</table>
											</div>
											<div id="merlinclash-content-config" style="margin:-1px 0px 0px 0px;">
												<table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable">
													<div id="merlinclash_dns_edit_content" style="margin-top:-1px;overflow:hidden;">
														<textarea rows="7" wrap="on" id="merlinclash_dns_edit_content1" name="dns_edit_content1" style="margin: 0px; width: 709px; height: 300px; resize: none;" readonly="true"></textarea>
													</div>
													<tr>
														<div class="apply_gen">
														<!--<a type="button" style="position: relative; vertical-align: middle; cursor:pointer"  class="ss_btn" onclick="dnsfilechange()">&nbsp;&nbsp;修改提交&nbsp;&nbsp;</a>	-->															
														<input class="button_gen" type="button" onclick="dnsfilechange()" value="修改提交">
													</div>
													</tr>
												</table>
											</div>
										</div>
										<!--操作日志-->
										<div id="tablet_5" style="display: none;">
											<div id="log_content" style="margin-top:-1px;overflow:hidden;">
												<textarea class="sbar" cols="63" rows="36" wrap="on" readonly="readonly" id="log_content1" style="margin: 0px; width: 709px; height: 645px; resize: none;"></textarea>
											</div>
										</div>
										<!--当前配置-->
										<div id="tablet_6" style="display: none;">
											<div id="yaml_content" style="margin-top:0px; width:750px; height: 650px;">
												<textarea class="sbar" cols="63" rows="36" wrap="on" readonly="readonly" id="yaml_content1" style="margin: 0px; width: 709px; height: 645px; resize: none;"></textarea>
											</div>
										</div>
										<!--dlercloud-->
										<div id="tablet_10" style="display: none;">
											<div id="dlercloud_login" style="margin-top:0px; width:750px; height: 150px;">
                                                <table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
													<thead>
														<tr>
															<td colspan="2">Dler Cloud登陆</td>
														</tr>
														</thead>
													<tr id="clash_loginname">
														<th>用户名</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<input id="merlinclash_dc_name" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">															
																														
																</div>
															</td>
                                                        </tr>
                                                        <tr id="clash_loginpasswd">
                                                            <th>密码</th>
                                                                <td>
                                                                    <div style="display:table-cell;float: left;margin-left:0px;">
                                                                        <input id="merlinclash_dc_passwd" type="password" style="color: #FFFFFF; width: 300px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;" placeholder="">															
                                                                                                                            
                                                                    </div>
                                                                </td>
                                                            </tr>
                                                            <tr id="clash_loginbtn">
                                                                <th>登陆</th>
                                                                    <td>
                                                                        <div style="display:table-cell;float: left;margin-left:0px;">
                                                                            <a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="dc_login()" href="javascript:void(0);">&nbsp;&nbsp;登陆&nbsp;&nbsp;</a>
																			&nbsp;&nbsp;
																			<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" href="https://dlercloud.com/auth/login" target="_blank">&nbsp;&nbsp;官网&nbsp;&nbsp;</a>
																                                           
                                                                        </div>
                                                                    </td>
                                                                </tr>
												</table>	
                                            </div>
                                            <div id="dlercloud_content" style="margin-top:0px; width:750px; height: 650px;">
                                                <table style="margin:-1px 0px 0px 0px;" width="100%" border="1" align="center" cellpadding="4" cellspacing="0" bordercolor="#6b8fa3" class="FormTable" >
                                                    <thead>
														<tr>
															<td colspan="2">Dler Cloud信息</td>
														</tr>
														</thead>
													<tr id="clash_loginname">
														<th>用户名</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_name"></span>	
																	<span id="dc_token" style="display: none;"></span>															
                                                                    <a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="dc_logout()" href="javascript:void(0);">&nbsp;&nbsp;退出&nbsp;&nbsp;</a>  													
																</div>
															</td>
													</tr>													
                                                    <tr id="clash_money">
														<th>余额</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_money"></span>															
                                                                    </div>
															</td>
													</tr> 
													<tr id="clash_affmoney">
														<th>返利</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_affmoney"></span>															
                                                                    </div>
															</td>
													</tr> 
													<tr id="clash_integral">
														<th>积分</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_integral"></span>															
                                                                    </div>
															</td>
                                                    </tr> 
                                                    <tr id="clash_plan">
														<th>当前套餐</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_plan"></span>															
                                                                    </div>
															</td>
                                                    </tr> 
                                                    <tr id="clash_plantime">
														<th>到期时间</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_plantime"></span>															
                                                                   </div>
															</td>
                                                    </tr> 
                                                    <tr id="clash_usedTraffic">
														<th>已用流量</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_usedTraffic"></span>															
                                                                  	</div>
														</td>
                                                    </tr> 
                                                    <tr id="clash_unusedTraffic">
														<th>可用流量</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_unusedTraffic"></span>															
                                                                  </div>
														</td>
													</tr>
													<thead>
														<tr>
															<td colspan="2">订阅相关 -- <em style="color: gold;">如重置过连接参数，需要退出重新登陆才可以订阅</em></td>
														</tr>
														</thead>
													
                                                    <tr id="clash_ss">
														<th>SS节点</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_ss"></span>						
                                                                    <a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="dc_ss_yaml(2)" href="javascript:void(0);">一键订阅</a>  													
																</div>
															</td>
                                                    </tr>
                                                    <tr id="clash_v2">
														<th>v2ray节点</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_v2"></span>															
                                                                    <a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="dc_v2_yaml(2)" href="javascript:void(0);">一键订阅</a>  													
																</div>
															</td>
                                                    </tr>
                                                    <tr id="clash_trojan">
														<th>trojan节点</th>
															<td>
																<div style="display:table-cell;float: left;margin-left:0px;">
																	<span id="dc_trojan"></span>															
                                                                    <a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="dc_tj_yaml(2)" href="javascript:void(0);">一键订阅</a>  													
																</div>
															</td>
													</tr>
													<tr>
														<th><br>SubConverter三合一转换
															<br>
															<br><em style="color: gold;">SS&nbsp;|&nbsp;SSR&nbsp;|&nbsp;V2ray订阅|&nbsp;Trojan订阅</em>
															<br><em style="color: gold;">内置Acl4ssr项目规则</em>	
															<br><em style="color: gold;">本地SubConverter进程转换</em>																
														</th>
														<td >																									
															<div class="SimpleNote" style="display:table-cell;float: left; width: 400px;">
																<label>emoji:</label>																
																<input id="merlinclash_dc_subconverter_emoji" type="checkbox" name="dc_subconverter_emoji" checked="checked">
																<label>启用udp:</label>																
																<input id="merlinclash_dc_subconverter_udp" type="checkbox" name="dc_subconverter_udp">
																<label>节点类型:</label>																
																<input id="merlinclash_dc_subconverter_append_type" type="checkbox" name="dc_subconverter_append_type">
																<label>节点排序:</label>																
																<input id="merlinclash_dc_subconverter_sort" type="checkbox" name="dc_subconverter_sort">
																<label>过滤非法节点:</label>																
																<input id="merlinclash_dc_subconverter_fdn" type="checkbox" name="dc_subconverter_fdn">
																<br>
																<label>Skip certificate verify:</label>																
																<input id="merlinclash_dc_subconverter_scv" type="checkbox" name="dc_subconverter_scv">
																<label>TCP Fast Open:</label>																
																<input id="merlinclash_dc_subconverter_tfo" type="checkbox" name="dc_subconverter_tfo">
															</div>
															<div class="SimpleNote" style="display:table-cell;float: left; width: 400px;">
																<p><label>包含节点：</label>
																	<input id="merlinclash_dc_subconverter_include" style="color: #FFFFFF; width: 320px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;筛选包含关键字的节点名，支持正则">
																</p>
																<br>
																<p><label>排除节点：</label>
																	<input id="merlinclash_dc_subconverter_exclude" style="color: #FFFFFF; width: 320px; height: 20px; background-color:rgba(87,109,115,0.5); font-family: Arial, Helvetica, sans-serif; font-weight:normal; font-size:12px;margin:-30px 0;" placeholder="&nbsp;过滤包含关键字的节点名，支持正则">
																</p>		
															</div>
															<div class="SimpleNote" style="display:table-cell;float: left; height: 30px; line-height: 30px; ">
																<select id="merlinclash_dc_clashtarget" style="width:75px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																	<option value="clash">clash新参数</option>
																	<option value="clashr">clashR新参数</option>						
																</select>
																<select id="merlinclash_dc_acl4ssrsel" style="width:220px;margin:0px 0px 0px 2px;text-align:left;padding-left: 0px;" class="input_option">
																	<option value="MC_Common">Merlin Clash_常规规则</option>
																	<option value="MC_Area_Fallback">Merlin Clash_分区域故障转移</option>
																	<option value="MC_Area_Urltest">Merlin Clash_分区域自动测速</option>
																	<option value="MC_Area_NoAuto">Merlin Clash_分区域无自动测速</option>
																	<option value="MC_Area_Media">Merlin Clash_媒体与分区域自动测速</option>
																	<option value="MC_Area_Media_NoAuto">Merlin Clash_媒体与分区域无自动测速</option>
																	<option value="Online">Online默认版_分组比较全</option>
																	<option value="AdblockPlus">AdblockPlus_更多去广告</option>	
																	<option value="NoAuto">NoAuto_无自动测速</option>	
																	<option value="NoReject">NoReject_无广告拦截规则</option>	
																	<option value="Mini">Mini_精简版</option>	
																	<option value="Mini_AdblockPlus">Mini_AdblockPlus_精简版更多去广告</option>	
																	<option value="Mini_NoAuto">Mini_NoAuto_精简版无自动测速</option>
																	<option value="Mini_Fallback">Mini_Fallback_精简版带故障转移</option>	
																	<option value="Mini_MultiMode">Mini_MultiMode_精简版自动测速故障转移负载均衡</option>	
																	<option value="Full">Full全分组_重度用户使用</option>
																	<option value="Full_NoAuto">Full全分组_无自动测速</option>
																	<option value="Full_AdblockPlus">Full全分组_更多去广告</option>
																	<option value="Full_Netflix">Full全分组_奈飞全量</option>																		
																</select>
																<a type="button" style="vertical-align: middle; margin:-10px 10px;" class="ss_btn" style="cursor:pointer" onclick="get_online_yaml4(21)" href="javascript:void(0);">&nbsp;&nbsp;开始转换&nbsp;&nbsp;</a>
															</div>
														</td>
													</tr>
                                                </table>
                                            </div>  
										</div>
										<!--底部按钮-->
										<div class="apply_gen" id="loading_icon">
											<img id="loadingIcon" style="display:none;" src="/images/InternetScan.gif">
										</div>
										<div id="delallpgnodes_button" class="apply_gen">
											<input class="button_gen" type="button" onclick="delallpgnodes()" value="全部删除">	
										</div>
										<div id="delallowneracls_button" class="apply_gen">
											<input class="button_gen" type="button" onclick="delallaclconfigs()" value="全部删除">	
										</div>
										<div id="apply_button" class="apply_gen">
											<input class="button_gen" type="button" onclick="apply()" value="保存&应用">
										</div>																															
									</td>
								</tr>
							</table>
						</div>
					</td>
				</tr>
			</table>
		</td>
		<td width="10" align="center" valign="top"></td>
	</tr>
</table>
<div id="footer"></div>
</body>
</html>