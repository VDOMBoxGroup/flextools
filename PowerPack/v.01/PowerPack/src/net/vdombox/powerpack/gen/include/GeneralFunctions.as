// ActionScript file
// General functions set

import connection.SOAPBaseLevel;

import flash.display.Bitmap;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.controls.Alert;
import mx.core.Application;
import mx.graphics.codec.JPEGEncoder;
import mx.graphics.codec.PNGEncoder;
import mx.utils.Base64Encoder;
import mx.utils.UIDUtil;

import net.vdombox.powerpack.BasicError;
import net.vdombox.powerpack.gen.GraphContext;
import net.vdombox.powerpack.gen.errorClasses.RunTimeError;
import net.vdombox.powerpack.gen.structs.GraphStruct;
import net.vdombox.powerpack.gen.structs.NodeStruct;
import net.vdombox.powerpack.lib.extendedapi.codec.BMPEncoder;
import net.vdombox.powerpack.lib.extendedapi.utils.FileToBase64;
import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
import net.vdombox.powerpack.managers.LanguageManager;
import net.vdombox.powerpack.panel.Question;

public function sub( graph : String, ...args ) : *
{
	var prefix : String = '';
	args.unshift( graph, prefix );
	return subPrefix.apply( this, args );
}

public function subPrefix( graph : String, prefix : String, ...args ) : *
{
	var subgraph : GraphStruct;

	for each ( var graphStruct : GraphStruct in tplStruct.graphs )
	{
		if ( graphStruct.name == graph )
			subgraph = graphStruct;
	}

	if ( subgraph )
	{
		return enterSubgraph.apply( this, [subgraph, prefix, args] );
	}
	else
	{
		throw new RunTimeError( "Undefined graph: " + graph + "." );
	}
}

private function enterSubgraph( subgraph : GraphStruct, prefix : String, params : Array = null ) : Function
{
	var graphContext : GraphContext = new GraphContext( subgraph );
	var curNode : NodeStruct = tplStruct.curGraphContext.curNode;

	graphContext.varPrefix = prefix;

	tplStruct.curNodeContext.block.retValue = subgraph.name;

	tplStruct.nodeStack.push( tplStruct.curNodeContext );

	tplStruct.contextStack.push( graphContext );

	tplStruct.step = 'parseNewNode';

	if ( tplStruct.forced >= 0 )
		tplStruct.forced++;

	if ( params && params.length > 0 )
	{
		for ( var i : int = 0; i < params.length; i++ )
			tplStruct.curGraphContext.context['param' + (i + 1)] = params[i];
	}

	Application.application.callLater( tplStruct.generate );

	return new Function;
}

private function __question( handler : Function, question : String, params : Array = null ) : Function
{
	var answersArray		: Array = [];
	var questionMode		: int;
	var questionFileFilter	: String;

	if ( !params ) params = [];

	questionMode = getQuestionMode(params);
	
	if (questionMode == Question.QM_BROWSE)
	{
		if ( params.length >= 1 )
		{
			questionFileFilter = getFileMask( params[0].toString() );
		}
	}
	
	if (questionMode == Question.QM_CHOICE)
	{
		for ( var i : int = 0; i < params.length; i++ )
			answersArray.push( params[i].toString() );
	}
	
	Question.show( question, "", questionMode, answersArray, questionFileFilter, null, handler );
	
	return handler;
}

private function getQuestionMode (params : Array) : int
{
	if (!params || params.length == 0)
		return Question.QM_QUESTION;
	
	if ( params.length == 1 && params[0].toString() == "*")
		return Question.QM_QUESTION;
	
	if ( params.length == 1 && isFileMaskParam(params[0].toString()) )
		return Question.QM_BROWSE;
	
	if (params.length > 1)
		return Question.QM_CHOICE;
	
	return Question.QM_QUESTION;
}

private var regExpFileMask : RegExp = /#\((\*.([\w]+|\*)(;[ ]*(\*.([\w]+|\*))+)*)*\)/g;

private function isFileMaskParam(param : String) : Boolean
{
	var arrMatch : Array = param.match(regExpFileMask);
	
	if (!arrMatch || arrMatch.length != 1)
		return false;
	
	return true;
}
private function getFileMask(param : String) : String
{
	if (!isFileMaskParam(param))
		return null;
	
	var arrMatch : Array = param.match(regExpFileMask);
	
	var maskGroup : String = String(arrMatch[0]).substring(2, String(arrMatch[0]).length-1);

	return maskGroup;
}

public function question( question : String, ...args ) : Function
{
	return __question( questionCloseHandler, question, args );

	function questionCloseHandler( event : Event ) : void
	{
		setReturnValue( event.target.strAnswer );
	}
}

public function qSwitch( question : String, ...args ) : Function
{
	return __question( questionCloseHandler, question, args );

	function questionCloseHandler( event : Event ) : void
	{
		var retVal : String = LanguageManager.sentences['other'] + '...';

		for each ( var arg : String in args )
		{
			if ( event.target.strAnswer == arg )
				retVal = event.target.strAnswer;
		}

		setReturnValue( retVal );
	}
}

public function _switch( value : String, ...args ) : String
{
	for each ( var arg : String in args )
	{
		if ( value == arg )
			return value;
	}

	return LanguageManager.sentences['other'] + '...';
}

public function convert( type : String, value : Object ) : Function
{
	var result : String;

	if ( value && type.toLowerCase() == "hexcolor" )
	{
		result = int( "0x" + value.toString().replace( /^#/g, "" ) ).toString();
	}
	else if ( value && type.toLowerCase() == "intcolor" )
	{
		result = int( value ).toString( 16 );
		while ( result.length < 6 )
		{
			result = result + "0";
		}
		result = "#" + result;
	}
	else if ( value && type.toLowerCase() == "base64" )
	{
		var fileToBase64 : FileToBase64 = new FileToBase64( value.toString() );
		fileToBase64.addEventListener( "dataConverted", completeConvertHandler );
		fileToBase64.loadAndConvert();
		return completeConvertHandler;

		function completeConvertHandler( event : Event ) : void
		{
			setReturnValue( event.target.data );
		}
	}

	Application.application.callLater( convertComplete, [result] );
	return convertComplete;

	function convertComplete( value : String ) : void
	{
		setReturnValue( value );
	}
}

public function imageToBase64( pic : Bitmap, type : String = null ) : String
{
	var data : ByteArray = new ByteArray();

	if ( type.toLowerCase() == "jpg" ||
			type.toLowerCase() == "jpeg" )
	{
		var jpgEncoder : JPEGEncoder = new JPEGEncoder( 80 );
		data = jpgEncoder.encode( pic.bitmapData );
	}
	else if ( type.toLowerCase() == "bmp" )
	{
		data = BMPEncoder.encode( pic.bitmapData );
	}
	else
	{
		var pngEncoder : PNGEncoder = new PNGEncoder();
		data = pngEncoder.encode( pic.bitmapData );
	}

	var encoder : Base64Encoder = new Base64Encoder();

	encoder.encodeBytes( data );
	var strData : String = encoder.flush();

	return strData;
}

public function writeTo( filePath : String ) : void
{
	var data : String = GraphContext( tplStruct.contextStack[0] ).buffer;
	data = Utils.replaceEscapeSequences( data, "\\-" );
	writeVarTo( filePath, data );
}

public function writeVarTo( filePath : String, value : Object ) : void
{
	// TODO: return operation result  ['error' 'description'] ['ok']
	if ( !(value && filePath) )
		return;
	
	var file : File = new File( filePath );

	if(file.isDirectory || file.isPackage ||file.isSymbolicLink)
		return;

	var data : ByteArray = objectToByteArray(value, file.extension);

	var fileStream : FileStream = new FileStream();

	fileStream.open( file, FileMode.WRITE );
	fileStream.writeBytes( data );
	fileStream.close();

}
private function objectToByteArray( value : Object, extension : String  ) : ByteArray
{
	var data : ByteArray = new ByteArray();

	if ( value is Bitmap )
	{
		var bitmap : Bitmap =  value as    Bitmap;

		switch (extension.toLowerCase() )
		{
			case "png":
			{
				var pngEncoder : PNGEncoder = new PNGEncoder();
				data = pngEncoder.encode( bitmap.bitmapData );

				break;
			}
			case "jpg":
			case "jpeg":
			{
				var jpgEncoder : JPEGEncoder = new JPEGEncoder( 80 );
				data = jpgEncoder.encode( bitmap.bitmapData );

				break;
			}
			default :
			{
				data = BMPEncoder.encode( bitmap.bitmapData );
			}
		}
	}
	else
	{
		data.writeUTFBytes( value.toString() );
	}

	return data;

}

public function loadDataFrom( filePath : String ) : Function
{
	try
	{
		if ( !filePath )
		{
			throw new BasicError( "Not valid filepath" );
		}

		var file : File = new File( filePath );

		if ( !file.exists )
		{
			throw new BasicError( "File does not exist" );
		}

		var fileStream : FileStream = new FileStream();
		fileStream.addEventListener( Event.COMPLETE, onFileLoaded );
		fileStream.addEventListener( IOErrorEvent.IO_ERROR, onFileStreamError );
		fileStream.openAsync( file, FileMode.READ );
	}
	catch ( e : * )
	{
		Application.application.callLater( onFileStreamError, [new IOErrorEvent( IOErrorEvent.IO_ERROR )] );

		return onFileStreamError;
	}

	return onFileLoaded;

	function onFileStreamError( event : IOErrorEvent ) : void
	{
		setTransition( 'false' );
		setReturnValue( 'false' );
	}

	function onFileLoaded( event : Event ) : void
	{
		var _stream : FileStream = event.target as FileStream;
		var _strData : String = _stream.readUTFBytes( _stream.bytesAvailable );
		_stream.close();

		setTransition( 'true' );
		setReturnValue( _strData );
	}
}

public function GUID() : String
{
	var guid : String = UIDUtil.createUID();
	return guid.toLowerCase();
}

public function mid( start : int, length : int, string : String ) : String
{
	var substr : String = string.substr( start, length );
	return substr;
}

public function replace( string : String, tgt : String, flags : String, src : String ) : String
{
	var regExp : RegExp = new RegExp( tgt, flags );
	var str : String = string.replace( regExp, src );
	return str;
}

public function split( delimiter : String, string : String ) : String
{
	var arr : Array = string.split( delimiter );
	var str : String = "[" + arr.join( " " ) + "]";
	return str;
}

public function random( value : int ) : String
{
	var rnd : int = int( Math.round( Math.random() * value ) );
	return rnd.toString();
}

public function alert( strr : String ) : void
{
	//Alert.show( strr );
}

public function wholeMethod( funct : String, ...args ) : Function
{
	var soapBaseLevel : SOAPBaseLevel = new SOAPBaseLevel();

	soapBaseLevel.addEventListener( SOAPBaseLevel.RESULT_RECEIVED, rusulGettedHandler, false, 0, true );
	soapBaseLevel.execute( funct, args );

	function rusulGettedHandler( event : Event ) : void
	{
		soapBaseLevel.removeEventListener( SOAPBaseLevel.RESULT_RECEIVED, rusulGettedHandler );
		setReturnValue( soapBaseLevel.result );
	}

	return rusulGettedHandler;
}
