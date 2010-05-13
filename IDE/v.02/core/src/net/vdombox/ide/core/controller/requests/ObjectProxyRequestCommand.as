package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ObjectAttributesVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.core.model.ObjectProxy;
	import net.vdombox.ide.core.model.PageProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ObjectProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var pageProxy : PageProxy;
			var objectProxy : ObjectProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var objectVO : ObjectVO;

			if ( body is ObjectVO )
				objectVO = body as ObjectVO;
			else if ( body.hasOwnProperty( "objectVO" ) )
				objectVO = body.objectVO as ObjectVO;
			else
				throw new Error( "no object VO" );

			pageProxy = facade.retrieveProxy( PageProxy.NAME + "/" + objectVO.pageVO.applicationVO.id + "/" + objectVO.pageVO.id ) as PageProxy;
			objectProxy = pageProxy.getObjectProxy( objectVO );

			switch ( target )
			{
				case PPMObjectTargetNames.ATTRIBUTES:
				{
					if( operation == PPMOperationNames.READ )
						objectProxy.getAttributes();
					else if( operation == PPMOperationNames.UPDATE )
						objectProxy.setAttributes( body as ObjectAttributesVO );

					break;
				}

				case PPMObjectTargetNames.SERVER_ACTIONS:
				{
					if( operation == PPMOperationNames.READ )
						objectProxy.getServerActions();
					else if( operation == PPMOperationNames.UPDATE )
						objectProxy.setServerActions( body.serverActions );

					break;
				}
					
				case PPMObjectTargetNames.OBJECT:
				{
					if( operation == PPMOperationNames.CREATE )
						objectProxy.createObject( body.typeVO, body.attributes );
					
					break;
				}
					
				case PPMObjectTargetNames.WYSIWYG:
				{
					if( operation == PPMOperationNames.READ )
						objectProxy.getWYSIWYG();
					
					break;
				}
					
				case PPMObjectTargetNames.XML_PRESENTATION:
				{
					if( operation == PPMOperationNames.READ )
						objectProxy.getXMLPresentation();
					else if( operation == PPMOperationNames.UPDATE )
						objectProxy.setXMLPresentation( body.xmlPresentation );
					
					break;
				}
			}
		}
	}
}