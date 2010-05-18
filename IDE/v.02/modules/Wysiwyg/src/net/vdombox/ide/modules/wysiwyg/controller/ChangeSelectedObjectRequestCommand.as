package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var objectVO : ObjectVO = notification.getBody() as ObjectVO;

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			if ( sessionProxy.selectedObject != objectVO ||
				( sessionProxy.selectedObject && objectVO && sessionProxy.selectedObject.id != objectVO.id ) )
			{
				sendNotification( ApplicationFacade.SET_SELECTED_OBJECT, objectVO );
			}
				
		}
	}
}