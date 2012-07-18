/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 16.07.12
 * Time: 18:33
 */
package net.vdombox.proshare.model
{
import flash.errors.IOError;
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.net.URLLoader;
import flash.net.URLLoaderDataFormat;
import flash.net.URLRequest;
import flash.net.URLRequestHeader;
import flash.net.URLRequestMethod;
import flash.system.System;
import flash.utils.ByteArray;

import mx.controls.Alert;

import net.vdombox.proshare.Event.FilesProxyEvent;

public class FileProxy    extends EventDispatcher
{
	public static var server : String;

	private var loader:URLLoader = new URLLoader ();
	private var request:URLRequest = new URLRequest ( server );

	private var _state : String = "";


	public static var outputPath : String;
	private var _file :File;


	public function FileProxy(target : IEventDispatcher = null )
	{
		super( target );




		loader.dataFormat =  URLLoaderDataFormat.BINARY;

//		request = new URLRequest ( server );

		request.requestHeaders =  new Array( new URLRequestHeader("Accept-Language", "ru-RU"));
		request.method = URLRequestMethod.POST;
	}
	private function loaderHandler (event : Event ):void
	{

		loader.removeEventListener( Event.COMPLETE, loaderHandler );
		loader.removeEventListener ( IOErrorEvent.IO_ERROR, loaderHandler);
		loader.removeEventListener ( SecurityErrorEvent.SECURITY_ERROR, loaderHandler );
		loader.removeEventListener ( ProgressEvent.PROGRESS, progressHandler );



		loader = null;

		if ( event && event.type == Event.COMPLETE)
		{
			safeFile(event.target.data, _fileVO );
		}
		else
		{
			_state = "Download file: " + _fileVO.title + " Error.";

			dispatchComplete();
		}


//			html.data =  event.target.data;
	}

	private function progressHandler( event:ProgressEvent ):void
	{
		dispatchEvent( event);
	}

	private function dispatchComplete():void
	{
		 dispatchEvent( new Event( Event.COMPLETE));
	}

	private var _fileVO :FileVO;
	public function download(): void
	{

//		createMessage("Downloading file: " + _fileVO.title);
		if ( file && file.exists )
		{
			_state =  "file already exists";
			dispatchComplete();
		}
		else if( _fileVO.size > 500 *1024* 1024) // > 500MB
		{
			var mess : String =  "File '"+_fileVO.title+ "' is more then 500 MB " + _fileVO.sizeString+".\n Please download the file manually on the link:\n" +
			server + "?" + _fileVO.vars;

			_state =  "\n\n******************\n"+ mess +"\n*************************\n";

			Alert.show(mess, "Attention")
			dispatchComplete();
		}   else
		{
			loader.addEventListener ( Event.COMPLETE, loaderHandler, false, 0 );
			loader.addEventListener ( IOErrorEvent.IO_ERROR, loaderHandler, false, 0 );
			loader.addEventListener ( SecurityErrorEvent.SECURITY_ERROR, loaderHandler, false, 0 );
			loader.addEventListener ( ProgressEvent.PROGRESS, progressHandler );


			request.data = _fileVO.vars;

			loader.load( request );

		}
	}

	private function get path(  ):String
	{
		var pth : String

		if (outputPath && fileVO )
		 pth = outputPath+"/"+ fileVO.spaceVO.name +"/"+fileVO.title

		return pth;
	}

	private  function safeFile( data : ByteArray, fileVO : FileVO): void
	{


		var fileStream : FileStream = new FileStream();


			try
			{

				fileStream.open( file, FileMode.WRITE );
				fileStream.writeBytes( data );
				fileStream.close();
				_state =  "Ok.";

			}
			catch ( error : IOError )
			{
				_state =  "Error: "+  error.message;

			}

		dispatchComplete();
	}

	private function createMessage( value : String ):void
	{
		trace(value)
		dispatchEvent( new FilesProxyEvent(FilesProxyEvent.MESSAGE, value));
	}

	public function set fileVO( value:FileVO ):void
	{
		_fileVO = value;
	}

	public function get state():String
	{
		return _state;
	}


	public function get fileVO():FileVO
	{
		return _fileVO;
	}

	public function get file():File
	{

		if ( !_file )
		try
		{
			_file = new File().resolvePath(path);
		}
		catch ( error : IOError )
		{
			_state =  "Error: "+  error.message;

		}
		return _file;
	}


	}


}
