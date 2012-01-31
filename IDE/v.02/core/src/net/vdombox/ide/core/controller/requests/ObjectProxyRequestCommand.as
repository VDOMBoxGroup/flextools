package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.controller.names.PPMObjectTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.model._vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.core.model.ObjectProxy;
	import net.vdombox.ide.core.model.PageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * @flowerModelElementId _DBoukEomEeC-JfVEe_-0Aw
	 */
	public class ObjectProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var pageProxy : PageProxy;
			var objectProxy : ObjectProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			var objectVO : ObjectVO;

			if ( body is ObjectVO )
				objectVO = body as ObjectVO;
			else if ( body.hasOwnProperty( "objectVO" ) )
				objectVO = body.objectVO as ObjectVO;
			else if ( body.hasOwnProperty( "vdomObjectVO" ) )
				objectVO = body.vdomObjectVO as ObjectVO;
			else
				throw new Error( "no object VO" );

			pageProxy = facade.retrieveProxy( PageProxy.NAME + "/" + objectVO.pageVO.applicationVO.id + "/" + objectVO.pageVO.id ) as PageProxy;
			objectProxy = pageProxy.getObjectProxy( objectVO );

			switch ( target )
			{
				case PPMObjectTargetNames.ATTRIBUTES:
				{
					if ( operation == PPMOperationNames.READ )
						objectProxy.getAttributes();
					else if ( operation == PPMOperationNames.UPDATE )
						objectProxy.setAttributes( body as VdomObjectAttributesVO );

					break;
				}

				case PPMObjectTargetNames.SERVER_ACTIONS_LIST:
				{
					if ( operation == PPMOperationNames.READ )
						objectProxy.getServerActionsList();
					else if( operation == PPMOperationNames.UPDATE )
						objectProxy.setServerActions(body.serverActions as Array);
					break;
				}
					
				case PPMObjectTargetNames.SERVER_ACTIONS:
				{
					if ( operation == PPMOperationNames.READ )
						objectProxy.getServerActions();
	
					break;
				}

				case PPMObjectTargetNames.SERVER_ACTION:
				{
					if ( operation == PPMOperationNames.CREATE )
						objectProxy.createServerAction( body.serverActionVO );
					else if ( operation == PPMOperationNames.READ )
						objectProxy.getServerAction( body.serverActionVO );
					else if ( operation == PPMOperationNames.UPDATE )
						objectProxy.setServerAction( body.serverActionVO );
					else if ( operation == PPMOperationNames.DELETE )
						objectProxy.deleteServerAction( body.serverActionVO );
					break;
				}

				case PPMObjectTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.CREATE )
						objectProxy.createObject( body.typeVO, body.attributes );

					break;
				}

				case PPMObjectTargetNames.WYSIWYG:
				{
					if ( operation == PPMOperationNames.READ )
						objectProxy.getWYSIWYG();

					break;
				}

				case PPMObjectTargetNames.XML_PRESENTATION:
				{
					if ( operation == PPMOperationNames.READ )
						objectProxy.getXMLPresentation();
					else if ( operation == PPMOperationNames.UPDATE )
						objectProxy.setXMLPresentation( body as VdomObjectXMLPresentationVO );

					break;
				}
					
				case PPMObjectTargetNames.REMOTE_CALL:
				{
					if ( operation == PPMOperationNames.READ )
						objectProxy.remoteCall( body.functionName, body.value );
					
					break;
				}

				case PPMObjectTargetNames.NAME:
				{
					if ( operation == PPMOperationNames.UPDATE )
						objectProxy.setName();

					break;
				}
					
				case PPMObjectTargetNames.COPY:
				{
					objectProxy.createCopy( body.sourceID as String );
					
					break;
				}
			}
		}
	}
}