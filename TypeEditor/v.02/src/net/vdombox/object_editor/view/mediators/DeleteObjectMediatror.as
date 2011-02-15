package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.filesystem.File;
	
	import flexlib.containers.SuperTabNavigator;
	
	import mx.utils.object_proxy;
	
	import net.vdombox.object_editor.model.Item;
	import net.vdombox.object_editor.model.proxy.FileProxy;
	import net.vdombox.object_editor.view.AccordionNavigatorContent;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.ObjectsAccordion;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.Button;

	public class DeleteObjectMediatror extends Mediator implements IMediator
	{
		public static const NAME:String = "DeleteObjectMediatror";
				
		public function DeleteObjectMediatror( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );
			view.addEventListener( MouseEvent.CLICK, deleteObject );			
		}
		
		private function deleteObject( event:Event = null ) : void
		{
			var objAcc:ObjectsAccordion = view.parentApplication.objAccordion as ObjectsAccordion;
			var accNav:AccordionNavigatorContent = objAcc.accordion.selectedChild as AccordionNavigatorContent;
			var item:Item	 = accNav.list.selectedItem as Item;
			var selIndex:int = accNav.list.selectedIndex as int;
			
			if (selIndex >= 0)
			{		
				var file:File = new File();
				file.nativePath = item.path;
				//tab close
				
				var tabNav:SuperTabNavigator = view.parentApplication.tabNavigator as SuperTabNavigator;
				var obj:ObjectView = tabNav.selectedChild as ObjectView;
				if (obj)
				{
					obj.dispatchEvent( new Event(ObjectViewMediator.OBJECT_TYPE_VIEW_REMOVED));
					
					var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
					var fileData: String	= fileProxy.readFile(file.nativePath);
					var xmlFile:XML = new XML(fileData);
					var id:String = xmlFile.Information.ID;
					
					facade.sendNotification(ObjectViewMediator.CLOSE_OBJECT_TYPE_VIEW, {"objView": obj, "id": id});
				}
				
				//delete obj from directory
//				var file:File = new File();
//				file.nativePath = item.path;
				
				var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
				fileProxy.deleteFile(file.nativePath);
				
				//delete from accordion				
				accNav.removeObject(selIndex);
			}
		}
		
		protected function get view():Button
		{
			return viewComponent as Button;
		}
	}
}