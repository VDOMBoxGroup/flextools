/**
 * Created by IntelliJ IDEA.
 * User: andreev ap
 * Date: 13.07.12
 * Time: 16:21
 */
package net.vdombox.proshare.model
{
import flash.events.Event;
import flash.events.EventDispatcher;
import flash.events.IEventDispatcher;
import flash.events.ProgressEvent;


import net.vdombox.proshare.Event.FilesProxyEvent;

public class FilesProxy  extends EventDispatcher
{

	private var _spacesVO : Object = {};

	private var _filesVO : Vector.<FileVO> = new Vector.<FileVO>;

	private var _fullSize : Number = 0;

	private  var downloadedSize : Number = 0;

	public function FilesProxy(target : IEventDispatcher = null )
	{
		super( target );


	}

	public function createSpacesVO( value : Object ):void
	{
		var spaceVO : SpaceVO;
	   	var xml : XML = value as XML;

		for each (var  space : XML in xml.queryresult.table.data.row )
		{
			spaceVO = new SpaceVO(space);

			_spacesVO[ spaceVO.guid ] = spaceVO;
		}
	}

	public function createFilesVO( value : Object ):void
	{
		var fileVO : FileVO;
		var spaceVO : SpaceVO;
		var xml : XML = value as XML;

		for each (var  space : XML in xml.queryresult.table.data.row )
		{
//			trace(space);
			fileVO = new FileVO(space);

			spaceVO = _spacesVO[ fileVO.spaceID ];
			if   (spaceVO)
			{
				spaceVO.addFileVO( fileVO );
				_filesVO.push( fileVO );

				_fullSize +=   fileVO.size;
			}
//			trace(fileVO.URL);
		}
	}


	public function get filesVO():Vector.<FileVO>
	{
		return _filesVO;
	}

	public function get spacesVO():Object
	{
		return _spacesVO;
	}

	public function get fullSize():String
	{
		var s : Number = Math.round( _fullSize / 1024.0/1024.0/1024.0*1000)/1000;

		return s.toString() + " Gb" ;
	}

	private var _server : String ;


	public function download(): void
	{
		trace("FsPr.dow()")
		if (filesVO.length == 0 )
		{
			 createMessage("No files to download.");
			return;
		}


		var fileVO : FileVO = filesVO.pop();
		var fileProxy : FileProxy = new FileProxy();

		fileProxy.addEventListener(Event.COMPLETE, fileProxyComplete, false, 0, true ) ;
		fileProxy.addEventListener(ProgressEvent.PROGRESS, fileProxyProgress, false, 0, true ) ;

		fileProxy.fileVO  = fileVO;

		createMessage("Downloading: " + fileVO.title + " " + fileVO.sizeString + " (" + fileVO.spaceVO.name+")"  );

		downloadedSize += fileVO.size;
		fileProxy.download();
	}

	private function fileProxyProgress( event:ProgressEvent ):void
	{
		dispatchEvent(event);
	}

	private function fileProxyComplete( event : Event ):void
	{
		var fileProxy : FileProxy = event.target as  FileProxy

		fileProxy.removeEventListener(Event.COMPLETE, fileProxyComplete) ;
		fileProxy.removeEventListener(ProgressEvent.PROGRESS, fileProxyProgress ) ;


		createMessage( fileProxy.state +"\n" );
//		createMessage( progress +"\n");

		download();
	}

	public function get progress(  ):String
	{
		var s : Number = Math.round( downloadedSize / 1024.0/1024.0/1024.0*1000)/1000;

		return "Total: " + s.toString() +" / "+	fullSize;
	}

//	TODO: переместить наверх
	public function set server( value:String ):void
	{
		_server =   "http://"+ value +"/get_file.vdom" ;

		FileProxy.server = _server;
	}






	private function createMessage( value : String ):void
	{
		trace(value)
		dispatchEvent( new FilesProxyEvent(FilesProxyEvent.MESSAGE, value));
	}

}
}
