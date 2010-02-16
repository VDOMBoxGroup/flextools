package net.vdombox.ide.modules.scripts.controller
{
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;

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

					if ( statesObject[ ApplicationFacade.SELECTED_OBJECT ] )
					{
						sendNotification( ApplicationFacade.CREATE_SEVER_ACTION,
										  { objectVO: statesObject[ ApplicationFacade.SELECTED_OBJECT ], name: scriptName, script: "" } );
					}

					else if ( statesObject[ ApplicationFacade.SELECTED_PAGE ] )
					{
						sendNotification( ApplicationFacade.CREATE_SEVER_ACTION,
										  { pageVO: statesObject[ ApplicationFacade.SELECTED_PAGE ], name: scriptName, script: "" } );
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