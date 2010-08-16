
//we don't want the flash islands to scroll the html page with mousewheel
function _onWheelScroll(event) {
	if (event && event.target.tagName == 'EMBED')
		event.preventDefault();
	else if (window.event && window.event.srcElement.tagName == 'OBJECT')
		window.event.returnValue = false;
}
if (!navigator.appVersion.match('Chrome') && window.addEventListener)
	window.addEventListener('DOMMouseScroll', _onWheelScroll, false);
else
	window.onmousewheel = document.onmousewheel = _onWheelScroll;



var popup;
var code;
var isPopup;
var source;
var mbCount = 0;

var playTarget;
setPlayTarget('swf');

var appDir = 'minibuilder/';

function hintErrors(ascOut)
{
	var editor = window.CodeAssist0 ? window.CodeAssist0 : document.CodeAssist0;
	
	var re = /^ERROR:\s(?:.*)\((\d+):\d+\)/gm;
	var mat, a = [], b = [];
	while (mat = re.exec(ascOut))
	{
		a.push(mat[1]);
	}
	var re = /\[Compiler\] Error #(.*)$/gm;
	while (mat = re.exec(ascOut))
		b.push(mat[1]);
	
	editor.hintErrors(a, b);
}

function compileCode(code)
{
	self.code = code;
	//document.jsap.compileSource(code);
	if (!popup || popup.closed)
	{
		var url = 'runPopup.html';
		if (!isPopup) url = appDir + url;
		popup = open(url, 'runpopup', 'width=650,height=650,scrollbars=1,resizable=1,toolbar=0,status=0,menubar=0,location=0');
	}
	else compileCode2();
}

function popupLoaded()
{
	compileCode2();
}

function compileCode2()
{
	popup.focus();
	try {
		popup.compileCode(code);
	} catch(e)
	{
		setTimeout(compileCode2, 500);
	}
}

function openInPopup(source)
{
	var url = 'popup.html';
	if (!isPopup) url = appDir + url;
	var w = open(url, '_blank', 'width=800,height=600,scrollbars=1,resizable=1,toolbar=0,status=0,menubar=0,location=0');
	w.window.isPopup = true;

	self.source = source;
}

function setPlayTarget(target)
{
	playTarget = {swf:'SWFPlayground.swf', aswing:'ASwingPlayground.swf'}[target];
	try {
		popup.close();
	} catch (e) { }
}

function getSource()
{
	return opener && opener.source ? opener.source : null;
}

function minibuilder(srcURL, height)
{
	writeSWF(appDir+'CodeAssist.swf', 'CodeAssist'+mbCount, null, null, height, {srcURL:srcURL});
	mbCount ++;
}

function writeSWF(src, name, bgcolor, w, h, params)
{
	if (!w) w = '100%';
	if (!h) h = '500';
	if (!name) name='CodeAssist';
	if (!bgcolor) bgcolor='#ffffbb';
	
	var fv = [];
	if (params)
	{
		for (var key in params)
			fv.push(encodeURIComponent(key) + '=' + encodeURIComponent(params[key])); 
	}
	fv = fv.join('&');
	
  	document.write('<object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000"'+
			(name ? ' id="'+name+'"' : '')+' width="'+w+'" height="'+h+'"'+
			'codebase="http://fpdownload.macromedia.com/get/flashplayer/current/swflash.cab">'+
			'<param name="movie" value="'+src+'" />'+
			'<param name="quality" value="high" />'+
			'<param name="bgcolor" value="'+bgcolor+'" />'+
			'<param name="allowScriptAccess" value="sameDomain" />'+
			'<param name="flashvars" value="' + fv + '"/>' +
			'<embed src="'+src+'" quality="high" bgcolor="'+bgcolor+'"'+
				'width="'+w+'" height="'+h+'"' + (name ? 'name="'+name+'"' : '') + ' align="middle"'+
				'play="true"'+
				'loop="false"'+
				'quality="high"'+
				'allowScriptAccess="sameDomain"'+
				'type="application/x-shockwave-flash"'+
				'flashvars="' + fv + '"' + 
				'pluginspage="http://www.adobe.com/go/getflashplayer">'+
			'</embed>'+
	'</object>');
}
