package net.vdombox.ide.core.controller.requests
{
	import net.vdombox.ide.common.PPMApplicationTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.common.vo.ApplicationInformationVO;
	import net.vdombox.ide.common.vo.ApplicationVO;
	import net.vdombox.ide.common.vo.LibraryVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.core.model.ApplicationProxy;
	import net.vdombox.ide.core.model.ServerProxy;

	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ApplicationProxyRequestCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;

			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;

			var body : Object = message.getBody();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();

			var applicationVO : ApplicationVO;

			if ( body is ApplicationVO )
				applicationVO = body as ApplicationVO;
			else if ( body && body.hasOwnProperty( "applicationVO" ) )
				applicationVO = body.applicationVO as ApplicationVO;
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
					applicationProxy.getServerActions();

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
					if ( operation == PPMOperationNames.CREATE )
					{
						var name : String = body.name;
						var script : String = body.script;

						if ( !name )
							break;

						applicationProxy.setLibrary( name, script );
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
						var libraryVO : LibraryVO = body.libraryVO;

						applicationProxy.removeLibrary( libraryVO );
					}

					break;
				}

				case PPMApplicationTargetNames.LIBRARIES:
				{
					applicationProxy.getLibraries();

					break;
				}

				case PPMApplicationTargetNames.EVENTS:
				{
					if ( operation == PPMOperationNames.READ )
						applicationProxy.getEvents( body.pageVO );

					break;
				}

				case PPMApplicationTargetNames.PAGES:
				{
					applicationProxy.getPages();

					break;
				}

				case PPMApplicationTargetNames.INFORMATION:
				{
					var applicationInformationVO : ApplicationInformationVO = body.applicationInformationVO;
					applicationProxy.changeApplicationInformation( applicationInformationVO );

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

					break;
				}
			}
		}
	}
}