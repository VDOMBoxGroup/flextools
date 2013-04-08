package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetScriptRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var body : Object = notification.getBody();
			var actionVO : Object = body.actionVO;
			var scriptName : String = actionVO.name;

			if ( actionVO is ServerActionVO )
			{
				var object : Object = actionVO.containerVO;

				if ( !object )
				{
					object = statesProxy.selectedObject;
					if ( !object )
						object = statesProxy.selectedPage;
				}


				if ( object is ObjectVO )
				{
					sendNotification( Notifications.GET_SERVER_ACTION, { objectVO: object, serverActionVO: actionVO, check: body.check } );
				}

				else if ( object is PageVO )
				{
					sendNotification( Notifications.GET_SERVER_ACTION, { pageVO: object, serverActionVO: actionVO, check: body.check } );
				}

			}

			else if ( actionVO is GlobalActionVO )
			{
				sendNotification( Notifications.GET_GLOBAL_ACTION, { applicationVO: statesProxy.selectedApplication, globalActionVO: actionVO as GlobalActionVO, check: body.check } );
			}

			else if ( actionVO is LibraryVO )
			{
				sendNotification( Notifications.GET_LIBRARY, { applicationVO: statesProxy.selectedApplication, libraryVO: actionVO as LibraryVO, check: body.check } );
			}


		}
	}
}
