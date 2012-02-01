package net.vdombox.ide.modules.scripts.controller
{
	import mx.utils.ObjectUtil;
	import mx.utils.UIDUtil;
	
	import net.vdombox.ide.common.model.SessionProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
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
			
			var actionVO : Object = body.currentVO;
			var scriptName : String = actionVO.name;

			if ( !selectedApplicationVO || !scriptName )
				return;

			if ( actionVO is ServerActionVO )
			{

				if ( body.hasOwnProperty( "objectVO" ) )
				{
					sendNotification( ApplicationFacade.SET_SERVER_ACTION,
						{ objectVO: body.objectVO, serverActionVO: actionVO } );
				}

				else if ( body.hasOwnProperty( "pageVO" )  )
				{
					sendNotification( ApplicationFacade.SET_SERVER_ACTION,
						{ pageVO: body.pageVO, serverActionVO: actionVO } );
				}

			}
			else if ( actionVO is GlobalActionVO )
			{
				sendNotification( ApplicationFacade.SAVE_GLOBAL_ACTION, { applicationVO: selectedApplicationVO, globalActionVO : actionVO as GlobalActionVO } );
			}
			
			else if ( actionVO is LibraryVO )
			{
				sendNotification( ApplicationFacade.SAVE_LIBRARY, { applicationVO: selectedApplicationVO, libraryVO : actionVO as LibraryVO } );
			}
			
		}
	}
}