package net.vdombox.object_editor.view.mediators
{	
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	import flash.system.System;
	
	import mx.utils.UIDUtil;
	
	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.model.proxy.ObjectsProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.view.ObjectsAccordion;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;
	
	//TODO: rename to loadButtonMediator
	public class CreateObjectMediator extends Mediator implements IMediator
	{		
		public static const NAME			:String = "CreateObjectMediator";
		public static const CREATE_GUIDS	:String = "CreateGUIDs";
		
		public function CreateObjectMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );
			view.addEventListener( MouseEvent.CLICK, newObject );			
		}		
		
		private function newObject( event:Event = null ) : void
		{
			sendNotification( ApplicationFacade.CRAETE_XML_FILE, view.parentApplication );
		}
		
		private function createGUIDs( file:File ) : void
		{
			var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
			var fileData: String	= fileProxy.readFile(file.nativePath);
			
			if (fileData != "")
			{
				var xmlFile:XML = new XML(fileData);
				
				//set Name
				xmlFile.Information.Name			=  file.name.split(".")[0];
				
				//set  DisplayName
				xmlFile.Languages.Language.Sentence[0]	=  file.name.split(".")[0];
				
				//set ID of Object
				xmlFile.Information.ID 				= UIDUtil.createUID();
				
				//add uids
				var uid:String = UIDUtil.createUID();
				xmlFile.Information.Icon			= "#Res(" + uid + ")";
				xmlFile.Resources.Resource.@ID[0]	= uid;
				
				uid = UIDUtil.createUID();
				xmlFile.Information.EditorIcon		= "#Res(" + uid + ")";
				xmlFile.Resources.Resource.@ID[1]	= uid;
				
				uid = UIDUtil.createUID();
				xmlFile.Information.StructureIcon	= "#Res(" + uid + ")";			
				xmlFile.Resources.Resource.@ID[2]	= uid;
				
				//save file with new value
				var str:String = xmlFile.toXMLString();
				fileProxy.saveFile( str, file.nativePath );
				
				addItemToAccordion(file, xmlFile);
			}			
		}	
		
		private function addItemToAccordion( file:File, xmlFile:XML ) : void
		{	
			//create Item and add it to Accordion	
			var itemProxy:ObjectsProxy = facade.retrieveProxy(ObjectsProxy.NAME) as ObjectsProxy;  //почему ObjectProxy
			var item:Item = itemProxy.getItem(file) ;					
			facade.sendNotification(ApplicationFacade.NEW_NAVIGATOR_CONTENT, item);
			
			//new Tab		
			var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;			
			objTypeProxy.newObjectTypeVO(xmlFile, item.path);
		}
		
		override public function listNotificationInterests():Array 
		{			
			return [ CREATE_GUIDS ];
		}
		
		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case CREATE_GUIDS:
				{
					createGUIDs(note.getBody() as File);
					break;	
				}
			}
		}
				
		protected function get view():Button
		{
			return viewComponent as Button;
		}
	}
}