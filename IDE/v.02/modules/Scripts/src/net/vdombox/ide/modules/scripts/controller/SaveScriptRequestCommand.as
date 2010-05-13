package net.vdombox.ide.modules.scripts.controller
{
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.LibraryVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	import net.vdombox.ide.modules.scripts.view.ServerScriptsPanelMediator;
	import net.vdombox.utils.MD5Utils;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class SaveScriptRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var selectedApplicationVO : ApplicationVO = sessionProxy.selectedApplication;

			var body : Object = notification.getBody();

			var scriptName : String = body.name;
			var script : String = body.script;

			if ( !selectedApplicationVO || !scriptName || !script )
				return;

			if ( body is ServerActionVO )
			{
				//TODO: сделать более полную обработку исключения...
				if ( !facade.hasMediator( ServerScriptsPanelMediator.NAME ) )
					return;

				var serverScriptsPanelMediator : ServerScriptsPanelMediator = facade.retrieveMediator( ServerScriptsPanelMediator.NAME ) as
					ServerScriptsPanelMediator;

				var serverActions : Array = serverScriptsPanelMediator.serverScripts;

				//TODO: сделать более полную обработку исключения...
				if ( !serverActions )
					return;

				if ( sessionProxy.selectedObject )
				{
					sendNotification( ApplicationFacade.SET_SERVER_ACTIONS,
						{ objectVO: sessionProxy.selectedObject, serverActions: serverActions } );
				}

				else if ( sessionProxy.selectedPage )
				{
					sendNotification( ApplicationFacade.SET_SERVER_ACTIONS,
						{ pageVO: sessionProxy.selectedPage, serverActions: serverActions } );
				}

			}
			else if ( body is LibraryVO )
			{
				sendNotification( ApplicationFacade.SAVE_LIBRARY, { applicationVO: selectedApplicationVO, libraryVO : body as LibraryVO } );
			}
		}
	}
}