package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
	import net.vdombox.ide.modules.scripts.view.ServerScriptsPanelMediator;

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

			var statesObject : Object = sessionProxy.getObject( ApplicationFacade.STATES );

			var selectedApplicationVO : ApplicationVO = statesObject[ ApplicationFacade.SELECTED_APPLICATION ] as ApplicationVO;

			if ( !selectedApplicationVO || !scriptName || !target )
				return;

			switch ( target )
			{
				case ApplicationFacade.ACTION:
				{

					var serverScriptsPanelMediator : ServerScriptsPanelMediator = facade.retrieveMediator( ServerScriptsPanelMediator.NAME ) as
						ServerScriptsPanelMediator;

					var serverActions : Array = serverScriptsPanelMediator.serverActions;
					var serverActionVO : ServerActionVO;

					if ( serverScriptsPanelMediator.selectedObjectVO )
					{
						serverActionVO = new ServerActionVO( scriptName, serverScriptsPanelMediator.selectedObjectVO );
						serverActionVO.script = "";
						
						serverActions.push( serverActionVO );

						sendNotification( ApplicationFacade.SET_SERVER_ACTIONS,
										  { objectVO: statesObject[ ApplicationFacade.SELECTED_OBJECT ], serverActions: serverActions } );
					}

					else if ( statesObject[ ApplicationFacade.SELECTED_PAGE ] )
					{
						serverActionVO = new ServerActionVO( scriptName, serverScriptsPanelMediator.selectedPageVO );
						serverActionVO.script = "";
						
						serverActions.push( serverActionVO );

						sendNotification( ApplicationFacade.SET_SERVER_ACTIONS,
										  { pageVO: statesObject[ ApplicationFacade.SELECTED_PAGE ], serverActions: serverActions } );
					}

					break;
				}

				case ApplicationFacade.LIBRARY:
				{
					sendNotification( ApplicationFacade.CREATE_LIBRARY, { applicationVO: selectedApplicationVO, name: scriptName, script: "" } );

					break;
				}
			}
		}
	}
}