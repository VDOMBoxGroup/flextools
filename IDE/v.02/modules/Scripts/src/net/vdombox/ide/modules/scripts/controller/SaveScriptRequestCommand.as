package net.vdombox.ide.modules.scripts.controller
{
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import net.vdombox.editors.HashLibraryArray;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.view.ServerScriptsPanelMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveScriptRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var selectedApplicationVO : ApplicationVO = statesProxy.selectedApplication;

			var body : Object = notification.getBody();
			
			var actionVO : Object = body;
			var scriptName : String = actionVO.name;

			if ( !selectedApplicationVO || !scriptName )
				return;

			if ( actionVO is ServerActionVO )
			{
				var object : Object = actionVO.containerVO;

				if ( object is ObjectVO )
				{
					sendNotification( Notifications.SET_SERVER_ACTION,
						{ objectVO: object, serverActionVO: actionVO } );
				}

				else if ( object is PageVO  )
				{
					sendNotification( Notifications.SET_SERVER_ACTION,
						{ pageVO: object, serverActionVO: actionVO } );
				}

			}
			else if ( actionVO is GlobalActionVO )
			{
				sendNotification( Notifications.SAVE_GLOBAL_ACTION, { applicationVO: selectedApplicationVO, globalActionVO : actionVO as GlobalActionVO } );
			}
			
			else if ( actionVO is LibraryVO )
			{
				HashLibraryArray.removeLibrary( LibraryVO( actionVO ).name );
				sendNotification( Notifications.SAVE_LIBRARY, { applicationVO: selectedApplicationVO, libraryVO : actionVO as LibraryVO } );
			}
			
		}
	}
}