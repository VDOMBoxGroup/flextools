package net.vdombox.ide.modules.applicationsManagment.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPlaceNames;
	import net.vdombox.ide.common.PPMResourcesTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.applicationsManagment.ApplicationFacade;
	import net.vdombox.ide.modules.applicationsManagment.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessResourceProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var resourceVO : ResourceVO;

			if ( body is ResourceVO )
				resourceVO = body as ResourceVO;
			else if ( body && body.hasOwnProperty( "applicationVO" ) )
				resourceVO = body.resourceVO as ResourceVO;
			else
				throw new Error( "no application VO" );

			switch ( target )
			{
				case PPMResourcesTargetNames.RESOURCE:
				{
					if ( operation == PPMOperationNames.READ )
					{
						var recipientsArray : Array;
						var recipients : Object = sessionProxy.getObject( PPMPlaceNames.RESOURCES );

						resourceVO = message.getBody() as ResourceVO;

						if ( recipients.hasOwnProperty( resourceVO.id ) )
						{
							recipientsArray = recipients[ resourceVO.id ];

							for ( var i : int = 0; i < recipientsArray.length; i++ )
							{
								sendNotification( ApplicationFacade.RESOURCE_LOADED + "/" + recipientsArray[ i ],
												  resourceVO );
							}
						}
						else
						{
							sendNotification( ApplicationFacade.RESOURCE_LOADED, resourceVO );
						}
					}
					else if ( operation == PPMOperationNames.CREATE )
					{
						resourceVO = message.getBody() as ResourceVO;

						sendNotification( ApplicationFacade.RESOURCE_SETTED, resourceVO );
					}

					break;
				}
			}
		}
	}
}