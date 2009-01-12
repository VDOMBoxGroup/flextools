// ActionScript file
// General functions set
import ExtendedAPI.com.graphics.codec.BMPEncoder;
import ExtendedAPI.com.utils.FileToBase64;

import PowerPack.com.gen.errorClasses.RunTimeError;
import PowerPack.com.gen.structs.GraphStruct;
import PowerPack.com.panel.Question;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.core.Application;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;
import mx.utils.Base64Encoder;
import mx.utils.StringUtil;


/**
 * sub function section
 */	
 /*
public function _sub(graph:Object, ...args):void
{
	args.unshift(graph, {type:'n', value:''});
	_subPrefix.apply(this, args);
}

/**
 * subPrefix function section
 */	
 /*	 
public function _subPrefix(graph:Object, prefix:Object, ...args):void
{
	var subgraph:GraphStruct;
	
	for each (var graphStruct:GraphStruct in tplStruct.graphs) {
		if(graphStruct.name == graph.value)	
			subgraph = graphStruct;
	}
	
	if(subgraph) {
		_enterSubgraph.apply(this, [subgraph, prefix.value, args]);
	} else {
		throw new RunTimeError("Undefined graph name: " + graph.value);
	}
}

private function _enterSubgraph(subgraph:GraphStruct, prefix:String, params:Array=null):void
{
	var graphContext:GraphContext = new GraphContext(subgraph);
	
	if(tplStruct.parsedNode.vars!=null && tplStruct.parsedNode.vars.length>0)
		graphContext.variable = tplStruct.parsedNode.vars[0];
		
	graphContext.varPrefix = prefix;
	
	tplStruct.parsedNode.value = subgraph.name;
	
	GraphContext(contextStack[contextStack.length-1]).curNode['parsedNode'] = parsedNode;
	nodeStack.push(new NodeContext(GraphContext(contextStack[contextStack.length-1]).curNode));
	
	contextStack.push(graphContext);
	
	if(forced>=0)
		forced++;
		
	step = 0;
	
	if(params && params.length>0)
	{
		for(var i:int=0; i<params.length; i++)
			contextStack[contextStack.length-1].context['param'+(i+1)] = params[i];
	}
	
	Application.application.callLater(generate);
}
		 		
/**
 * question function section
 */	
 /*	 
public function _question(question:String, answers:String):Function
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
		array = answers.split(/\s*,\s*/
		/*);
	}
							
	Question.show(question, "", mode, array, filter, null, questionCloseHandler);
	
	return questionCloseHandler;
	
	function questionCloseHandler(event:Event):void {
		parsedNode.value = event.target.strAnswer;		
		Application.application.callLater(generate);	
	}	
}


/**
 * convert function section
 */		 
 /*
public function _convert(type:String, value:Object):void
{
	var result:String;
	
	if(value && type.toLowerCase() == "hexcolor")
	{
		result = int("0x" + value.toString().replace(/^#/g, "")).toString();
		Application.application.callLater(convertComplete, [result]);
	}
	else if(value && type.toLowerCase() == "intcolor")
	{				
		result = int(value).toString(16);
		while(result.length<6)
		{
			result = result + "0";
		}
		result = "#" + result;
			
		Application.application.callLater(convertComplete, [result]);
	}
	else if(value && type.toLowerCase() == "base64")
	{
		var fileToBase64:FileToBase64 = new FileToBase64(value.toString());
		fileToBase64.addEventListener("dataConverted", completeConvertHandler);
		fileToBase64.loadAndConvert();
		
		function completeConvertHandler(event:Event):void {
			Application.application.callLater(convertComplete, [event.target.data]);
		}
	}
	else
	{			
		Application.application.callLater(generate);
	}
	
	function convertComplete(value:String):void {
		parsedNode.value = value;		
		Application.application.callLater(generate);
	}
}


/**
 * writeTo function section
 */	
 /*	
public function _writeTo(filename:String):void
{			
	var data:String = GraphContext(contextStack[0]).buffer;
	data = Utils.replaceEscapeSequences(data, "\\-");
	_writeVarTo(filename, data);
}			 

public function _imageToBase64(pic:Bitmap, type:String=null):String
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
	
	Application.application.callLater(generate);
	
	return strData;
} 
 		
/**
 * writeVarTo function section
 */		
 /*
public function _writeVarTo(filename:String, value:Object):void
{
	if(value && filename && FileUtils.isValidPath(filename))
	{			
   		var file:File = new File();
   		file.url = FileUtils.pathToUrl(filename);       			

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
		
   		
   		if(!file.isDirectory)
   		{
        	var fileStream:FileStream = new FileStream();

			fileStream.open(file, FileMode.WRITE);
			fileStream.writeBytes(data);
			fileStream.close();
   		}
	}
	
	Application.application.callLater(generate);
}

/**
 * loadDataFrom function section
 */	
 /*	
public function _loadDataFrom(filename:String):void
{	
	try 
	{		
		if(!filename || !FileUtils.isValidPath(filename))
		{
			throw new BasicError("Not valid filename");
		}
	
		var file:File = new File();
		file.url = FileUtils.pathToUrl(filename);
	
		if(!file.exists)
		{
			throw new BasicError("File does not exists");
		}
		
		var fileStream:FileStream = new FileStream();
		fileStream.addEventListener( IOErrorEvent.IO_ERROR, onFileStreamError );
		fileStream.addEventListener( Event.COMPLETE, onFileLoaded );
		fileStream.openAsync(file, FileMode.READ);
	}
	catch(e:*)
	{
		Application.application.callLater(onFileStreamError, [new IOErrorEvent(IOErrorEvent.IO_ERROR)]);		
	}

	function onFileStreamError(event:IOErrorEvent):void {
		//throw new BasicError("IOError exception occurs");
		parsedNode.value = null;
		parsedNode.transition = 'false';
		
		Application.application.callLater(generate);	
	}
	
	function onFileLoaded(event:Event):void {
		var fileStream:FileStream = event.target as FileStream;
		var bytes:ByteArray = new ByteArray();
		parsedNode.value = fileStream.readUTFBytes(fileStream.bytesAvailable);
		parsedNode.transition = 'true';
		
		Application.application.callLater(generate);
	}
}

/**
 * GUID function section
 */		 
 /*
public function _GUID():String
{
	var guid:String = UIDUtil.createUID();
	
	Application.application.callLater(generate);
	
	return guid;
}	

/**
 * mid function section
 */		
 /* 
public function _mid(start:int, length:int, string:String):String
{
	var substr:String = string.substr(start, length);
	
	Application.application.callLater(generate);
	
	return substr;
}

/**
 * replace function section
 */		
 /* 
public function _replace(string:String, tgt:String, flags:String, src:String):String
{
	var regExp:RegExp = new RegExp(tgt, flags);		
	var str:String = string.replace(regExp, src);
	
	Application.application.callLater(generate);
	
	return str;
}

/**
 * split function section
 */		 
/*
public function _split(delimiter:String, string:String):String
{
	var arr:Array = string.split(delimiter);
	var str:String = "["+arr.join(" ")+"]";
	
	Application.application.callLater(generate);
	
	return str;
}

/**
 * random function section
 */		 
public function random(value:int):int 
{
	var rnd:int = int(Math.round(Math.random() * value)); 
	
	return rnd;
}	

