package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.net.FileReference;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ResourcesProxy;
	import net.vdombox.object_editor.model.vo.ResourceVO;
	import net.vdombox.object_editor.view.essence.Information;
	import net.vdombox.object_editor.view.essence.Resourses;
	import net.vdombox.object_editor.view.mediators.InformationMediator;
	import net.vdombox.object_editor.view.mediators.ObjectViewMediator;
	import net.vdombox.object_editor.view.mediators.ResourcesMediator;
	
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class UpdateResourceCommand extends SimpleCommand
	{
		override public function execute( note:INotification ) :void
		{
			var id: String = note.getBody() as String;
			
			var name : String = note.getName();
			var changeID : Boolean = false;
			
			switch ( name )
			{
				case ResourcesMediator.UPDATE_ICON:
				{
					changeID = true;
					
					break;
				}
			}

			var fileRef:FileReference = new FileReference();
			fileRef.addEventListener(Event.SELECT, fileSelected);

			fileRef.browse();

			function  fileSelected(event:Event):void
			{
				fileRef.addEventListener(Event.COMPLETE, fileDounloaded);
				fileRef.load();
			}

			function fileDounloaded(event:Event):void
			{				
				var resourcesProxy:ResourcesProxy = facade.retrieveProxy(ResourcesProxy.NAME) as ResourcesProxy;
				var resVO: ResourceVO = resourcesProxy.changeContent(id, changeID, fileRef);
				
				//if ( changeID )
				//{
					facade.sendNotification(ResourcesMediator.RESOURCE_CHANGED,{ resourceVO : resVO, oldID : id } );
//				}
//				else
//				{
//					facade.sendNotification(Information.INFORMATION_CHANGED);
//					facade.sendNotification(Resourses.RESOURCES_CHANGED);	
//				}
				//facade.sendNotification( ResourcesMediator.RESOURCE_UPLOADED, resVO );
			}
		}
	}
}

