package net.vdombox.ide.modules.events.controller
{
	import mx.utils.UIDUtil;
	
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.view.EventsPanelMediator;
	
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
					if ( !facade.hasMediator( EventsPanelMediator.NAME ) )
						return;
					
					var eventsPanelMediator : EventsPanelMediator = facade.retrieveMediator( EventsPanelMediator.NAME ) as
						EventsPanelMediator;
					
					var serverActions : Array = eventsPanelMediator.scripts;
					
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
			}
		}
	}
}