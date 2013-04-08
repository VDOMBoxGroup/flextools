package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.controller.names.PPMPageTargetNames;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.model._vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.PageProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * @flowerModelElementId _DBsY8EomEeC-JfVEe_-0Aw
	 */
	public class PageProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var applicationProxy : ApplicationProxy;
			var pageProxy : PageProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			if ( !body )
				return;

			var pageVO : PageVO;

			if ( body is PageVO )
				pageVO = body as PageVO;
			else if ( body.hasOwnProperty( "pageVO" ) )
				pageVO = body.pageVO as PageVO;
			else if ( body.hasOwnProperty( "vdomObjectVO" ) )
				pageVO = body.vdomObjectVO as PageVO;
			else
				throw new Error( "no page VO" );

			applicationProxy = facade.retrieveProxy( ApplicationProxy.NAME + "/" + pageVO.applicationVO.id ) as ApplicationProxy;

			if ( !applicationProxy )
				return;

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
					var isFind : Boolean = body.hasOwnProperty( "isFind" ) ? body.isFind : false;
					pageProxy.getStructure( isFind );

					break;
				}

				case PPMPageTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.READ )
						pageProxy.getObjectAt( body.objectID );
					else if ( operation == PPMOperationNames.CREATE )
						pageProxy.createObject( body.typeVO, body.attributes, body.name );
					else if ( operation == PPMOperationNames.DELETE )
					{
						if ( body.objectVO is ObjectVO )
							pageProxy.deleteObject( body.objectVO );
						else
							pageProxy.deleteObjects( body.objectVO );
					}


					break;
				}

				case PPMPageTargetNames.ATTRIBUTES:
				{
					if ( operation == PPMOperationNames.READ )
						pageProxy.getAttributes();
					else if ( operation == PPMOperationNames.UPDATE )
					{
						var vdomObjectAttributesVO : VdomObjectAttributesVO;

						if ( body is VdomObjectAttributesVO )
							vdomObjectAttributesVO = body as VdomObjectAttributesVO;
						else if ( body.hasOwnProperty( "vdomObjectAttributesVO" ) )
							vdomObjectAttributesVO = body.vdomObjectAttributesVO as VdomObjectAttributesVO;

						if ( vdomObjectAttributesVO )
							pageProxy.setAttributes( vdomObjectAttributesVO );
					}

					break;
				}

				case PPMPageTargetNames.NAME:
				{
					if ( operation == PPMOperationNames.UPDATE )
						pageProxy.setName();

					break;
				}

				case PPMPageTargetNames.SERVER_ACTIONS_LIST:
				{
					if ( operation == PPMOperationNames.READ )
						pageProxy.getServerActionsList();
					else if ( operation == PPMOperationNames.UPDATE )
						pageProxy.setServerActions( body.serverActions as Array );

					break;
				}
				case PPMPageTargetNames.SERVER_ACTIONS:
				{
					if ( operation == PPMOperationNames.READ )
						pageProxy.getServerActions();

					break;
				}

				case PPMPageTargetNames.ALL_SERVER_ACTIONS:
				{
					if ( operation == PPMOperationNames.READ )
						pageProxy.getAllServerActions();

					break;
				}

				case PPMPageTargetNames.SERVER_ACTION:
				{
					if ( operation == PPMOperationNames.CREATE )
						pageProxy.createServerAction( body.serverActionVO );
					else if ( operation == PPMOperationNames.READ )
						pageProxy.getServerAction( body.serverActionVO, body.check );
					else if ( operation == PPMOperationNames.UPDATE )
						pageProxy.setServerAction( body.serverActionVO );
					else if ( operation == PPMOperationNames.DELETE )
						pageProxy.deleteServerAction( body.serverActionVO );
					else if ( operation == PPMOperationNames.RENAME )
						pageProxy.renameServerAction( body.serverActionVO, body.newName );
					break;
				}

				case PPMPageTargetNames.WYSIWYG:
				{
					if ( operation == PPMOperationNames.READ )
						pageProxy.getWYSIWYG();

					break;
				}

				case PPMPageTargetNames.REMOTE_CALL:
				{
					if ( operation == PPMOperationNames.READ )
						pageProxy.remoteCall( body.functionName, body.value );

					break;
				}

				case PPMPageTargetNames.XML_PRESENTATION:
				{
					if ( operation == PPMOperationNames.READ )
						pageProxy.getXMLPresentation();
					else if ( operation == PPMOperationNames.UPDATE )
						pageProxy.setXMLPresentation( body as VdomObjectXMLPresentationVO );

					break;
				}

				case PPMPageTargetNames.COPY:
				{
					pageProxy.createCopy( body.sourceID as String );

					break;
				}
			}
		}
	}
}