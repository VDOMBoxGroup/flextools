package net.vdombox.object_editor.controller
{
	import flash.events.Event;
	import flash.net.FileReference;

	import net.vdombox.object_editor.model.proxy.componentsProxy.ResourcesProxy;
	import net.vdombox.object_editor.model.vo.ResourceVO;
	import net.vdombox.object_editor.view.mediators.ResourcesMediator;

	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.command.SimpleCommand;

	public class UpdateResourceCommand extends SimpleCommand
	{
		override public function execute( note:INotification ) :void
		{

			var resVO: ResourceVO = note.getBody() as ResourceVO;

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

				resourcesProxy.changeContent(resVO, fileRef);
			}
		}
	}
}
