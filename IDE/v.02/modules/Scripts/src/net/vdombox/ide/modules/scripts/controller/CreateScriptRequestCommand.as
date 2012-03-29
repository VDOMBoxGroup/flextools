package net.vdombox.ide.modules.scripts.controller
{
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.utils.MD5Utils;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateScriptRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var scriptName : String = body.name;
			var target : String = body.target;

			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var selectedApplicationVO : ApplicationVO = statesProxy.selectedApplication;

			if ( !selectedApplicationVO || !scriptName || !target )
				return;

			switch ( target )
			{
				case Notifications.ACTION:
				{

					var serverActionVO : ServerActionVO;

					serverActionVO = new ServerActionVO();
					serverActionVO.setID( UIDUtil.createUID() );
					serverActionVO.setName( scriptName );
					serverActionVO.script = "";

					if ( statesProxy.selectedObject )
					{
						sendNotification( Notifications.CREATE_SERVER_ACTION,
							{ objectVO: statesProxy.selectedObject, serverActionVO: serverActionVO } );
					}

					else if ( statesProxy.selectedPage )
					{
						sendNotification( Notifications.CREATE_SERVER_ACTION,
							{ pageVO: statesProxy.selectedPage, serverActionVO: serverActionVO } );
					}

					break;
				}

				case Notifications.LIBRARY:
				{
					var libraryVO : LibraryVO = new LibraryVO( scriptName, selectedApplicationVO );
					libraryVO.script = "";
					
					sendNotification( Notifications.CREATE_LIBRARY, { applicationVO: selectedApplicationVO, libraryVO : libraryVO } );

					break;
				}
			}
		}
	}
}