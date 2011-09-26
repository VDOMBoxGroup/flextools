package net.vdombox.ide.core.controller
{
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.core.model.ResourcesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class GetResourceItemRendererCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Object = notification.getBody();
			var resourceVO : ResourceVO;
			
			var resourcesProxy : ResourcesProxy = facade.retrieveProxy( ResourcesProxy.NAME ) as ResourcesProxy;
			
			if( body is ResourceVO )
				resourceVO = body as ResourceVO;
			else if( body.hasOwnProperty( "resourceVO" ) )
				resourceVO = body.resourceVO;
			
			var nameMed : String;
			if( body.hasOwnProperty( "recipientKey" ) )
				nameMed = body.recipientKey as String;
			
			
			if( resourceVO )
				resourcesProxy.loadResource2( resourceVO, nameMed ); 

		}
		
		
	}
}