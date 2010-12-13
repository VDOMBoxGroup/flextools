package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.SharedObject;
	
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	
	import org.osmf.utils.OSMFStrings;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class SaveAsObjectTypeCommand extends SimpleCommand 
	{
		override public function execute( note:INotification ) :void
		{
			var objTypeVO:ObjectTypeVO = note.getBody() as ObjectTypeVO;
						
			//get content of folder
			var so:SharedObject = SharedObject.getLocal("directoryPath");
			var path:String = so.data.path;
		
			//save as
			var docsDir:File = new File;
			docsDir.nativePath = path;
			try
			{
				docsDir.browseForSave("Save As");
				docsDir.addEventListener(Event.SELECT, saveData);
			}
			catch (error:Error)
			{
				trace("Failed:", error.message);
			}
			
			function saveData(event:Event):void 
			{	
				//save information
				var _information:XML = new XML("<Information/>");				
				_information.Name = objTypeVO.name;
//				_information.DisplayName = objTypeVO.displayName;	
//				_information.XMLScriptName = objTypeVO.;	
//				_information.RenderType = objTypeVO.renderType;
//				_information.Description = objTypeVO.description;
				_information.ClassName = objTypeVO.className;
				_information.ID = objTypeVO.id;
				_information.Category = objTypeVO.category;
				_information.Version = objTypeVO.version;
				_information.OptimizationPriority = objTypeVO.optimizationPriority;
//				_information.WCAG = objTypeVO;
				_information.Containers = objTypeVO.container;
//				_information.RemoteMethods = objTypeVO.;
//				_information.Handlers = objTypeVO;
				_information.Moveable = objTypeVO.moveable;
				_information.Dynamic = objTypeVO.dynamic;
				_information.InterfaceType = objTypeVO.interfaceType;
				_information.Resizable = objTypeVO.resizable;
				_information.Container = objTypeVO.container;
				
//TODO: надо создавть строчку: <?xml version="1.0" encoding="utf-8"?> ????????
				
				var _type:XML = new XML("<Type/>");
				_type.appendChild(_information);
			
				_type.SourceCode = objTypeVO.sourceCode;
				
				//save to file
				var newFile:File = event.target as File;
				newFile.nativePath = newFile.nativePath + ".xml";
				var str:String = _type.toXMLString();
				if (!newFile.exists)
				{
					var stream:FileStream = new FileStream();
					stream.open(newFile, FileMode.WRITE);
					stream.writeUTFBytes(str);
					stream.close();
				}
			}						
		}
	}
}