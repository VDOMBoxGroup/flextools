package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.ObjectAttributesVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var needForUpdateObject : Object = sessionProxy.needForUpdate;
			
			var renderProxy : RenderProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			var objectVO : ObjectVO = body.objectVO as ObjectVO;
			
			switch ( target )
			{
				case PPMObjectTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.CREATE )
					{
						sendNotification( ApplicationFacade.OBJECT_CREATED, body.newObjectVO );
						sendNotification( ApplicationFacade.GET_WYSIWYG, sessionProxy.selectedPage );
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
						sendNotification( ApplicationFacade.OBJECT_DELETED, body.objectVO );
						sendNotification( ApplicationFacade.GET_WYSIWYG, sessionProxy.selectedPage );
					}

					break;
				}

				case PPMObjectTargetNames.ATTRIBUTES:
				{
					var objectAttributesVO : ObjectAttributesVO = body.objectAttributesVO as ObjectAttributesVO;

					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED, objectAttributesVO );
					else if ( operation == PPMOperationNames.UPDATE )
						sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED, objectAttributesVO );

//					if ( needForUpdateObject.hasOwnProperty( objectAttributesVO.objectVO.id ) )
//						sendNotification( ApplicationFacade.GET_OBJECT_WYSIWYG, objectAttributesVO.objectVO );

					break;
				}
					
				case PPMObjectTargetNames.WYSIWYG:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.WYSIWYG_GETTED, body );
					
					break;
				}
					
				case PPMObjectTargetNames.XML_PRESENTATION:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.XML_PRESENTATION_GETTED, body );
					else if ( operation == PPMOperationNames.UPDATE )
						sendNotification( ApplicationFacade.XML_PRESENTATION_SETTED, body );
					
					break;
				}
			}
		}
	}
}