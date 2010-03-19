<cfsilent>
	<cfsetting showdebugoutput="false" />
	<cfscript>
		bulletLimit = 6;
		if (Not StructKeyExists(cookie, 'cfrr.shot')) {
			cookie.cfrr.shot = 0;
			cookie.cfrr.bullet = RandRange(1, 6);
		}
		index = ArrayNew(1);

		jSesTracker = CreateObject('java', 'coldfusion.runtime.SessionTracker');
		oSess = jSesTracker.getSessionKeys();

		while (oSess.hasMoreElements()) {
			ArrayAppend(index, oSess.nextElement());
		}

		ArraySort(index, 'textnocase');
		sessionCount = ArrayLen(index);
		if (sessionCount Gt 0) {
			sessionPick = RandRange(1, sessionCount);
		} else {
			sessionPick = 0;
		}

		killed = false;
		shot = false;
		if (StructKeyExists(form, 'fire') And form.fire Eq 'Fire!') {
			if (sessionCount Eq 0) {
				StructDelete(cookie, 'cfrr.shot');
				StructDelete(cookie, 'cfrr.bullet');
				message = 'There were no sessions to shoot at :-(';
			} else {
				cookie.cfrr.shot = cookie.cfrr.shot + 1;
				if (cookie.cfrr.shot Gt bulletLimit) {
					StructDelete(cookie, 'cfrr.shot');
					StructDelete(cookie, 'cfrr.bullet');
					message = 'Reloading, must have forgot the bullet!?';
				} else if (cookie.cfrr.shot Eq cookie.cfrr.bullet) {
					shot = true;
					StructDelete(cookie, 'cfrr.shot');
					StructDelete(cookie, 'cfrr.bullet');
					message = 'BANG! I hope you can live with yourself, you just killed "' & index[sessionPick] & '"!';
					if (StructKeyExists(form, 'safety') And form.safety Eq 'On') {
						message = message & '... don''t worry, the safety was on :).';
						killed = true;
					} else {
						target = jSesTracker.getSession(index[sessionPick]);
						killed = Duplicate(target);
						target.setMaxInactiveInterval(1);
						StructClear(target);
					}
				} else {
					shot = true;
					message = '"CLICK!", Empty chamber! You just saved "' & index[sessionPick] & '"''s life!';
				}
			}
		} else {
			message = '';
		}
	</cfscript>
</cfsilent><!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN"	"http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
<head>
	<meta http-equiv="content-type" content="text/html; charset=utf-8" />
	<title>ColdFusion Session - Russian Roulette</title>
	<link type="text/css" href="css/smoothness/jquery-ui-1.8rc3.custom.css" rel="stylesheet" />	
	<script type="text/javascript" src="js/jquery-1.4.2.min.js"></script>
	<script type="text/javascript" src="js/jquery-ui-1.8rc3.custom.min.js"></script>
	<style type="text/css">
		html {font-size:100%;}
		body {
			font:62.5% "Trebuchet MS",Verdana,Helvetica,Arial,sans-serif !important;
			margin:0; padding:0;
			background-color: #050505;
			color:white;
			text-align:center;
		}
		#body {padding:10px; width:700px; text-align:left; margin: 0 auto; background-color:#2c3b50;}
		#gun {background: url('gun1.png') top right no-repeat; height:250px; padding-top:15px; position:relative;}
		#sessions {height:40px; overflow:hidden; width:300px; position:relative; border:1px solid white;}
		#sessions ol {list-style:none; margin:0; padding:0;}
		#sessions li {list-style:none; padding:0; background-color:black; color:white; height:38px; overflow:hidden; border:1px solid white;}
		#safety {position:absolute; top:52px; right:87px;}
		#trigger {position:absolute; top:100px; right:120px;}
		#flame {position:absolute; top:-20px; right:380px; display:none;}
		#dump {color:black;}
		#output {display:none; border:5px solid #777; margin:10px; padding:10px;}
	</style>
	<script type="text/javascript">
		<cfif shot>
			$(function() {
				$('#sessions li').each(function(key, value) {
					if (value.innerHTML == <cfoutput>'#JsStringFormat(index[sessionPick])#'</cfoutput>) {
						$(value.parentNode.parentNode).animate({scrollTop: $(value).position().top + 1}, 5000, function() {
							<cfif IsStruct(killed) Or killed>
								$(value).animate({backgroundColor: '#aa3636'}, 1000, function() {
									$(value).effect('explode', 1000, function() {
										$(value).css({
											display: '',
											visibility: 'hidden'
										});
									});
								});
								$('#flame').show('slide', {direction: 'right'});
								
							<cfelse>
								$(value).animate({backgroundColor: 'green'});
							</cfif>
							$('#output').show('slide', {direction: 'down'});
							$('#trigger').attr({'disabled': ''});
						});
					}
				});
			});
		</cfif>
	</script>
</head>
<body>
	<div id="body">
		<h1>Coldfusion Session Random Russian Roulette</h1>
		<p>One gun, six chambers, one bullet.  Each time you pull the trigger, it's pointed at a randomly selected session.  If it's the unlucky one, it's a goner!  There is a safety catch on the gun for cowards.</p>
		<div id="gun">
			<div id="sessions">
			<ol>
			<cfif shot>
				<cfoutput><cfloop from="1" to="#sessionCount#" index="sess">
					<li>#HtmlEditFormat(index[sess])#</li>
				</cfloop></cfoutput>
			</cfif>
			</ol>
			</div>
			<img src="flame.gif" height="120" width="180" id="flame" />
			<form method="post" action="index.cfm">
				<input type="checkbox" name="safety" id="safety" value="On" <cfif StructKeyExists(form, 'safety') And form.safety Eq 'On'>checked="checked"</cfif> />
				<input type="submit" name="fire" id="trigger" value="Fire!" <cfif shot>disabled="disabled"</cfif> />
			</form>
		</div>
		<div id="output">
			<h2><cfoutput>#HtmlEditFormat(message)#</cfoutput></h2>
			<cfif IsStruct(killed)><div id="dump"><cfdump var="#killed#" /></cfif>
		</div>
		<p>Please note that Coldfusion doesn't clean up the body straight away (usually about 10 seconds) so you may see a dead session mentioned again.  But dead is dead, it's emptied and is marked for deletion within a second.</p>
	</div>
</body>
</html>