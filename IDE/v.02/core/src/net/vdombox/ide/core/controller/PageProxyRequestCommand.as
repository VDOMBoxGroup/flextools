package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.PageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class PageProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var applicationProxy : ApplicationProxy;
			var pageProxy : PageProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var pageVO : PageVO;

			if ( body is PageVO )
				pageVO = body as PageVO;
			else if ( body.hasOwnProperty( "pageVO" ) )
				pageVO = body.pageVO as PageVO;
			else
				throw new Error( "no page VO" );

			applicationProxy = facade.retrieveProxy( ApplicationProxy.NAME + "/" + pageVO.applicationVO.id ) as ApplicationProxy;
			pageProxy = applicationProxy.getPageProxy( pageVO ) as PageProxy;

			switch ( target )
			{
				case PPMPageTargetNames.OBJECTS:
				{
					pageProxy.getObjects();

					break;
				}

				case PPMPageTargetNames.STRUCTURE:
				{
					pageProxy.getStructure();

					break;
				}

				case PPMPageTargetNames.OBJECT:
				{
					if( operation == PPMOperationNames.READ )
						pageProxy.getObjectAt( body.objectID );
					else if( operation == PPMOperationNames.CREATE )
						pageProxy.createObject( body.typeVO, body.attributes );
					else if( operation == PPMOperationNames.DELETE )
						pageProxy.deleteObject( body.objectVO );
					

					break;
				}

				case PPMPageTargetNames.ATTRIBUTES:
				{
					if( operation == PPMOperationNames.READ )
						pageProxy.getAttributes();
					else if( operation == PPMOperationNames.UPDATE )
						pageProxy.setAttributes( body as PageAttributesVO );

					break;
				}
					
				case PPMPageTargetNames.SERVER_ACTIONS:
				{
					if( operation == PPMOperationNames.READ )
						pageProxy.getServerActions();
					else if( operation == PPMOperationNames.UPDATE )
						pageProxy.setServerActions( body.serverActions );
					
					break;
				}
					
				case PPMPageTargetNames.WYSIWYG:
				{
					if( operation == PPMOperationNames.READ )
						pageProxy.getWYSIWYG();
					
					break;
				}
			}
		}
	}
}