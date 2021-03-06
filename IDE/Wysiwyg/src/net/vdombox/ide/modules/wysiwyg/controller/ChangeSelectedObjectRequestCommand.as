package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ChangeSelectedObjectRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var objectVO : IVDOMObjectVO = notification.getBody() as IVDOMObjectVO;

			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var selectedObject : ObjectVO = statesProxy.selectedObject;
			var selectedPage : PageVO = statesProxy.selectedPage;

			if ( selectedObject != objectVO || ( selectedObject && objectVO && selectedObject.id != objectVO.id ) )
			{
				var pageVO : PageVO;
				if ( objectVO is PageVO )
					pageVO = objectVO as PageVO;
				else if ( "pageVO" in objectVO )
					pageVO = objectVO[ "pageVO" ];

				if ( ( !selectedPage && pageVO ) || ( selectedPage && pageVO && selectedPage.id != pageVO.id ) )
					sendNotification( StatesProxy.SET_SELECTED_PAGE, pageVO );

				sendNotification( StatesProxy.SET_SELECTED_OBJECT, objectVO );
			}
		}
	}
}
