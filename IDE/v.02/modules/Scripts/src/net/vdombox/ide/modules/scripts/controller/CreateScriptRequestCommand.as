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

	public class CreateScriptRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();

			var scriptName : String = body.name;
			var target : String = body.target;

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var selectedApplicationVO : ApplicationVO = sessionProxy.selectedApplication;

			if ( !selectedApplicationVO || !scriptName || !target )
				return;

			switch ( target )
			{
				case ApplicationFacade.ACTION:
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

					var serverActionVO : ServerActionVO;

					serverActionVO = new ServerActionVO();
					serverActionVO.setID( UIDUtil.createUID() );
					serverActionVO.setName( scriptName );
					serverActionVO.script = "";

					serverActions.push( serverActionVO );

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

					break;
				}

				case ApplicationFacade.LIBRARY:
				{
					var libraryVO : LibraryVO = new LibraryVO( scriptName, selectedApplicationVO );
					libraryVO.script = "";
					
					sendNotification( ApplicationFacade.CREATE_LIBRARY, { applicationVO: selectedApplicationVO, libraryVO : libraryVO } );

					break;
				}
			}
		}
	}
}