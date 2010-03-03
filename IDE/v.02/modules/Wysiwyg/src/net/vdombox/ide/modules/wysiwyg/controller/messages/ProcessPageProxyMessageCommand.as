package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.PageAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var place : String = message.getPlace();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			switch ( target )
			{
				case PPMPageTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.CREATE )
					{
						sendNotification( ApplicationFacade.OBJECT_CREATED, body.objectVO );
						sendNotification( ApplicationFacade.GET_PAGE_WYSIWYG, sessionProxy.selectedPage );
					}
					else if ( operation == PPMOperationNames.READ )
					{
						sendNotification( ApplicationFacade.OBJECT_GETTED, body.objectVO );
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
						sendNotification( ApplicationFacade.OBJECT_DELETED, body.objectVO );
						sendNotification( ApplicationFacade.GET_PAGE_WYSIWYG, sessionProxy.selectedPage );
					}

					break;
				}

				case PPMPageTargetNames.WYSIWYG:
				{
					if ( operation == PPMOperationNames.READ )
						renderProxy.setRawRenderData( body.wysiwyg as XML );

					break;
				}

				case PPMPageTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.PAGE_STRUCTURE_GETTED, body );

					break;
				}

				case PPMPageTargetNames.ATTRIBUTES:
				{
					var pageAttributesVO : PageAttributesVO = body.pageAttributesVO as PageAttributesVO;

					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_GETTED, pageAttributesVO );
					else if ( operation == PPMOperationNames.UPDATE )
					{
//						for each ( recipientID in pageRecipient )
//						{
//							sendNotification( ApplicationFacade.PAGE_ATTRIBUTES_SETTED + ApplicationFacade.DELIMITER + recipientID, pageAttributesVO );
//						}
//
//						var mediatorName : String = TreeElementMediator.NAME + ApplicationFacade.DELIMITER + pageAttributesVO.pageVO.id;
//
//						if ( facade.hasMediator( mediatorName ) )
//						{
//							var treeElementMediator : TreeElementMediator = facade.retrieveMediator( mediatorName ) as TreeElementMediator;
//							treeElementMediator.pageAttributesVO = pageAttributesVO;
//						}
					}

					break;
				}
			}
		}
	}
}