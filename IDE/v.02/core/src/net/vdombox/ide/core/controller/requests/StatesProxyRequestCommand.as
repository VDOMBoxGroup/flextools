package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMStatesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.StatesProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StatesProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			var resultMessage : ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var properties : Object;
			var isResult : Boolean = true;

			switch ( target )
			{
				case PPMStatesTargetNames.ALL_STATES:
				{
					if ( operation == PPMOperationNames.READ )
					{
						properties = {};
						
						properties[ "selectedApplication" ] = statesProxy.selectedApplication;
						properties[ "selectedPage" ] = statesProxy.selectedPage;
						properties[ "selectedObject" ] = statesProxy.selectedObject;
						
					}
					
					break;
				}
				
				case PPMStatesTargetNames.SELECTED_APPLICATION:
				{
					if ( operation == PPMOperationNames.READ )
					{
						properties = statesProxy.selectedApplication;
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						statesProxy.selectedApplication = body as ApplicationVO;
						properties = body;
					}
					
					break;
				}

				case PPMStatesTargetNames.SELECTED_PAGE:
				{
					if ( operation == PPMOperationNames.READ )
					{
						properties = statesProxy.selectedPage;
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						statesProxy.selectedPage = body as PageVO;
						properties = body;
					}

					break;
				}

				case PPMStatesTargetNames.SELECTED_OBJECT:
				{
					if ( operation == PPMOperationNames.READ )
					{
						properties = statesProxy.selectedObject;
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						statesProxy.selectedObject = body as ObjectVO;
						properties = body;
					}

					break;
				}

				default:
				{
					isResult = false;
				}
			}

			if ( !isResult )
				return;

			resultMessage = new ProxiesPipeMessage( PPMPlaceNames.STATES, operation, target, properties );

			sendNotification( ApplicationFacade.STATES_PROXY_RESPONSE, resultMessage );
		}
	}
}