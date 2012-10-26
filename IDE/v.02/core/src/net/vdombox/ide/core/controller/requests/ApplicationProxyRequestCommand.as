package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.controller.messages.ProxyMessage;
	import net.vdombox.ide.common.controller.names.PPMApplicationTargetNames;
	import net.vdombox.ide.common.controller.names.PPMOperationNames;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.core.ApplicationFacade;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ServerProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	/**
	 * @flowerModelElementId _DBlEMEomEeC-JfVEe_-0Aw
	 */
	public class ApplicationProxyRequestCommand extends SimpleCommand 
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;

			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			var applicationVO : ApplicationVO;
			var libraryVO : LibraryVO;
			var globalActionVO : GlobalActionVO;

			if ( body is ApplicationVO )
				applicationVO = body as ApplicationVO;
			else if ( body && body.hasOwnProperty( "applicationVO" ) )
				applicationVO = body.applicationVO as ApplicationVO;
			else if ( body && body.hasOwnProperty( "applicationEventsVO" ) )
				applicationVO = body.applicationEventsVO.pageVO.applicationVO as ApplicationVO;
			else
				throw new Error( "no application VO" );

			var applicationProxy : ApplicationProxy;
			applicationProxy = serverProxy.getApplicationProxy( applicationVO );

			switch ( target )
			{
				case PPMApplicationTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
					{
						applicationProxy.getStructure();
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
						applicationProxy.setStructure( body.structure );
					}

					break;
				}

				case PPMApplicationTargetNames.SERVER_ACTIONS:
				{
					var isFind : Boolean = body.hasOwnProperty( "isFind" ) ? body.isFind : false;
					
					if ( operation == PPMOperationNames.READ )
					{
						applicationProxy.getServerActions("application", null, false, isFind);
						applicationProxy.getServerActions("session", null, false, isFind);
						applicationProxy.getServerActions("request", null, false, isFind);
					}
					break;
				}

				case PPMApplicationTargetNames.REMOTE_CALL:
				{
					if ( operation == PPMOperationNames.READ )
						applicationProxy.remoteCall( body.objectID, body.functionName, body.value );

					break;
				}

				case PPMApplicationTargetNames.LIBRARY:
				{
					libraryVO = body.libraryVO as LibraryVO;
					
					if ( operation == PPMOperationNames.READ )
						applicationProxy.getLibrary( libraryVO, body.check as Boolean );
					else if ( operation == PPMOperationNames.CREATE )
						applicationProxy.createLibrary( libraryVO );
					else if ( operation == PPMOperationNames.UPDATE )
						applicationProxy.updateLibrary( libraryVO );
					else if ( operation == PPMOperationNames.DELETE )
						applicationProxy.deleteLibrary( libraryVO );

					break;
				}

				case PPMApplicationTargetNames.LIBRARIES:
				{
					var isFind : Boolean = body.hasOwnProperty( "isFind" ) ? body.isFind : false;
					applicationProxy.getLibraries( isFind );

					break;
				}
					
				case PPMApplicationTargetNames.GLOBAL_ACTION:
				{
					globalActionVO = body.globalActionVO as GlobalActionVO;
					
					if ( operation == PPMOperationNames.READ )
					{
						applicationProxy.getServerActions("application", globalActionVO, body.check);
						applicationProxy.getServerActions("session", globalActionVO, body.check);
						applicationProxy.getServerActions("request", globalActionVO, body.check);
					}
					else if ( operation == PPMOperationNames.UPDATE )
						applicationProxy.updateGlobal( globalActionVO );
					
					break;
				}

				case PPMApplicationTargetNames.EVENTS:
				{
					if ( operation == PPMOperationNames.READ )
						applicationProxy.getEvents( body.pageVO );
					else if( operation == PPMOperationNames.UPDATE )
						applicationProxy.setEvents( body.applicationEventsVO, body.needForUpdate );

					break;
				}

				case PPMApplicationTargetNames.PAGES:
				{
					applicationProxy.getPages();
					break;
				}

				case PPMApplicationTargetNames.INFORMATION:
				{
					if ( operation == PPMOperationNames.UPDATE )
					{
						//var applicationInformationVO : ApplicationInformationVO = body.applicationInformationVO;
						//applicationProxy.changeApplicationInformation( applicationInformationVO );
						sendNotification(ApplicationFacade.PAGE_SET_AS_INDEX, { pageID: body.pageID} );
					}

					break;
				}

				case PPMApplicationTargetNames.PAGE:
				{
					if ( operation == PPMOperationNames.CREATE )
					{
						var typeVO : TypeVO = body.typeVO;

						applicationProxy.createPage( typeVO );
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
						var pageVO : PageVO = body.pageVO as PageVO;

						applicationProxy.deletePage( pageVO );
					}
					else if ( operation == PPMOperationNames.READ )
					{
						var pageID : String = body.pageID as String;
						
						applicationProxy.getPageAt( pageID );
					}

					break;
				}
					
				case PPMApplicationTargetNames.COPY:
				{
					applicationProxy.createCopy( body.sourceID as String );
					
					break;
				}
					
				case PPMApplicationTargetNames.ERROR:
				{
					sendNotification( ApplicationFacade.WRITE_ERROR, { text : body.content }  );
					
					break;
				}
					
				case PPMApplicationTargetNames.SAVED:
				{
					sendNotification( ApplicationFacade.APPLICATION_SAVE_CHECKED, body.saved );
					
					break;
				}
			}
		}
	}
}