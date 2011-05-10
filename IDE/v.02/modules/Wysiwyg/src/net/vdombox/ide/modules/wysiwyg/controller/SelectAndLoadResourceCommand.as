package net.vdombox.ide.modules.wysiwyg.controller
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.net.FileFilter;
	import flash.net.FileReference;
	import flash.utils.ByteArray;
	
	import mx.utils.Base64Encoder;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * SelectAndLoadResourceCommand - browse window
	 * for chose resource and send notification on server
	 * for set new resource.
	 *  
	 * @author Elena Kotlova
	 */
	public class SelectAndLoadResourceCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var app:ApplicationVO = notification.getBody() as ApplicationVO;
			var openFile:File = new File();			
			
			openFile.addEventListener(Event.SELECT, fileSelected);	
			
			var allFilesFilter : FileFilter = new FileFilter( "All Files (*.*)", "*.*" );
			var imagesFilter : FileFilter = new FileFilter( 'Images (*.jpg;*.jpeg;*.gif;*.png)', '*.jpg;*.jpeg;*.gif;*.png' );
			var docFilter : FileFilter = new FileFilter( 'Documents (*.pdf;*.doc;*.txt)', '*.pdf;*.doc;*.txt' );			
			
			openFile.browseForOpen( "Choose file to upload", [ imagesFilter, docFilter, allFilesFilter ] );			
			
			function fileSelected(event:Event):void
			{
				openFile.addEventListener(Event.COMPLETE, fileDounloaded);
				openFile.load();				
			}		
			
			function fileDounloaded(event:Event):void
			{				
				// compress and encode to base64 in Server
				var resourceVO : ResourceVO = new ResourceVO( app.id );
				resourceVO.setID( openFile.name );//?
				resourceVO.data = openFile.data;
				resourceVO.name = openFile.name;
				
				sendNotification( ApplicationFacade.SET_RESOURCE, resourceVO );
			}
		}
	}
}