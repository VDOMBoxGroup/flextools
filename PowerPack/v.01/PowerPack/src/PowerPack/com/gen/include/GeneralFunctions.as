// ActionScript file
// General functions set
import ExtendedAPI.com.graphics.codec.BMPEncoder;
import ExtendedAPI.com.utils.FileToBase64;
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.BasicError;
import PowerPack.com.gen.NodeContext;
import PowerPack.com.gen.errorClasses.RunTimeError;
import PowerPack.com.gen.structs.GraphStruct;
import PowerPack.com.gen.structs.NodeStruct;
import PowerPack.com.panel.Question;

import flash.display.Bitmap;
import flash.events.Event;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.core.Application;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;
import mx.utils.Base64Encoder;
import mx.utils.StringUtil;
import mx.utils.UIDUtil;

public function sub(graph:Object, ...args):*
{
	var prefix:Object = {type:'n', value:''};
	args.unshift(graph, prefix);
	return subPrefix.apply(this, args);
}

public function subPrefix(graph:Object, prefix:Object, ...args):*
{
	var subgraph:GraphStruct;
	
	for each (var graphStruct:GraphStruct in tplStruct.graphs) {
		if(graphStruct.name == graph.value)	
			subgraph = graphStruct;
	}
	
	if(subgraph) {
		return enterSubgraph.apply(this, [subgraph, prefix.value, args]);
	} else {
		throw new RunTimeError("Undefined graph: " + graph.value + ".");
	}
}

private function enterSubgraph(subgraph:GraphStruct, prefix:String, params:Array=null):Function
{
	var graphContext:GraphContext = new GraphContext(subgraph);
	var curNode:NodeStruct = tplStruct.curGraphContext.curNode;
	
	// get variable name if defined
	if(curNode.parsedNode.vars!=null && 
		curNode.parsedNode.vars.length>curNode.parsedNode.current &&
		curNode.parsedNode.vars[curNode.parsedNode.current])
		graphContext.variable = curNode.parsedNode.vars[curNode.parsedNode.current];
		
	graphContext.varPrefix = prefix;
	
	curNode.parsedNode.value = subgraph.name;
	
	tplStruct.nodeStack.push(new NodeContext(curNode));
	
	tplStruct.contextStack.push(graphContext);

	tplStruct.step = 'parseNewNode';

	if(tplStruct.forced>=0)
		tplStruct.forced++;
	
	if(params && params.length>0)
	{
		for(var i:int=0; i<params.length; i++)
			tplStruct.curGraphContext.context['param'+(i+1)] = params[i];
	}
	
	Application.application.callLater(tplStruct.generate);
	
	return new Function;
}
 	 
public function question(question:String, answers:String):Function
{
	var array:Array = null;
	var mode:int;
	var filter:String = "*.*";

	answers = StringUtil.trim(answers);

	if(answers == "*")
	{
		mode = Question.QM_QUESTION
	}
	else if(answers.charAt(0) == "#")
	{
		mode = Question.QM_BROWSE
		filter = answers.substring(1);
	}
	else
	{
		mode = Question.QM_CHOICE;
		array = answers.split(/\s*,\s*/);
	}
							
	Question.show(question, "", mode, array, filter, null, questionCloseHandler);
	
	return questionCloseHandler;
	
	function questionCloseHandler(event:Event):void {
		setReturnValue(event.target.strAnswer);
	}	
}

public function convert(type:String, value:Object):Function
{
	var result:String;
	
	if(value && type.toLowerCase() == "hexcolor")
	{
		result = int("0x" + value.toString().replace(/^#/g, "")).toString();
	}
	else if(value && type.toLowerCase() == "intcolor")
	{
		result = int(value).toString(16);
		while(result.length<6) {
			result = result + "0";
		}
		result = "#" + result;
	}
	else if(value && type.toLowerCase() == "base64")
	{
		var fileToBase64:FileToBase64 = new FileToBase64(value.toString());
		fileToBase64.addEventListener("dataConverted", completeConvertHandler);
		fileToBase64.loadAndConvert();		
		return completeConvertHandler;
		
		function completeConvertHandler(event:Event):void {
			setReturnValue(event.target.data);
		}
	}

	Application.application.callLater(convertComplete, [result]);
	return convertComplete;
	
	function convertComplete(value:String):void {
		setReturnValue(value);
	}
}

public function imageToBase64(pic:Bitmap, type:String=null):String
{
	var data:ByteArray = new ByteArray();

	if( type.toLowerCase()=="jpg" ||
		type.toLowerCase()=="jpeg" )
	{
		var jpgEncoder:JPEGEncoder = new JPEGEncoder(80);
		data = jpgEncoder.encode(pic.bitmapData);
	}
	else if(type.toLowerCase()=="bmp")
	{
		data = BMPEncoder.encode(pic.bitmapData);
	}
	else
	{
		var pngEncoder:PNGEncoder = new PNGEncoder();
		data = pngEncoder.encode(pic.bitmapData);
	}
	
	var encoder:Base64Encoder = new Base64Encoder();
	
	encoder.encodeBytes(data);
	var strData:String = encoder.flush();
	
	return strData;
} 

public function writeTo(filePath:String):void
{			
	var data:String = GraphContext(tplStruct.contextStack[0]).buffer;
	data = Utils.replaceEscapeSequences(data, "\\-");
	writeVarTo(filePath, data);
}			 
 		
public function writeVarTo(filePath:String, value:Object):void
{
	if(value && filePath)
	{			
   		var file:File = new File(filePath);		      			
		var data:ByteArray = new ByteArray();
		
		if(value is Bitmap)
		{
			if(file.extension.toLowerCase()=="png")
			{
				var pngEncoder:PNGEncoder = new PNGEncoder();
				data = pngEncoder.encode((value as Bitmap).bitmapData);
			}
			else if( file.extension.toLowerCase()=="jpg" ||
					 file.extension.toLowerCase()=="jpeg" )
			{
				var jpgEncoder:JPEGEncoder = new JPEGEncoder(80);
				data = jpgEncoder.encode((value as Bitmap).bitmapData);
			}
			else
			{
				data = BMPEncoder.encode((value as Bitmap).bitmapData);
			}
		}
		else
			data.writeUTFBytes(value.toString());
		
   		
   		if(!file.isDirectory && !file.isPackage && !file.isSymbolicLink)
   		{
        	var fileStream:FileStream = new FileStream();

			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(data);
			fileStream.close();
   		}
	}
}

public function loadDataFrom(filePath:String):Function
{	
	try 
	{		
		if(!filePath)
		{
			throw new BasicError("Not valid filepath");
		}
	
		var file:File = new File(filePath);
	
		if(!file.exists)
		{
			throw new BasicError("File does not exist");
		}
		
		var fileStream:FileStream = new FileStream();
		fileStream.addEventListener( IOErrorEvent.IO_ERROR, onFileStreamError );
		fileStream.addEventListener( Event.COMPLETE, onFileLoaded );
		fileStream.openAsync(file, FileMode.READ);
	}
	catch(e:*)
	{
		Application.application.callLater(onFileStreamError, [new IOErrorEvent(IOErrorEvent.IO_ERROR)]);		
		
		return onFileStreamError;		
	}
		
	return onFileLoaded;

	function onFileStreamError(event:IOErrorEvent):void {
		setTransition('false');
		setReturnValue('false');
	}
	
	function onFileLoaded(event:Event):void {
		var fileStream:FileStream = event.target as FileStream;
		var bytes:ByteArray = new ByteArray();
		
		setTransition('true');
		setReturnValue(fileStream.readUTFBytes(fileStream.bytesAvailable));
	}
}

public function GUID():String
{
	var guid:String = UIDUtil.createUID();
	return guid;
}	

public function mid(start:int, length:int, string:String):String
{
	var substr:String = string.substr(start, length);
	return substr;
}

public function replace(string:String, tgt:String, flags:String, src:String):String
{
	var regExp:RegExp = new RegExp(tgt, flags);		
	var str:String = string.replace(regExp, src);
	return str;
}

public function split(delimiter:String, string:String):String
{
	var arr:Array = string.split(delimiter);
	var str:String = "["+arr.join(" ")+"]";
	return str;
}

public function random(value:int):String 
{
	var rnd:int = int(Math.round(Math.random() * value)); 	
	return rnd.toString();
}	

