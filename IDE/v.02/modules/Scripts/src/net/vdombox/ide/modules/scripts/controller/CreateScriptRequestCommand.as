package net.vdombox.ide.modules.scripts.controller
{
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
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

			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var selectedApplicationVO : ApplicationVO = statesProxy.selectedApplication;

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

					if ( statesProxy.selectedObject )
					{
						sendNotification( ApplicationFacade.SET_SERVER_ACTIONS,
							{ objectVO: statesProxy.selectedObject, serverActions: serverActions } );
					}

					else if ( statesProxy.selectedPage )
					{
						sendNotification( ApplicationFacade.SET_SERVER_ACTIONS,
							{ pageVO: statesProxy.selectedPage, serverActions: serverActions } );
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