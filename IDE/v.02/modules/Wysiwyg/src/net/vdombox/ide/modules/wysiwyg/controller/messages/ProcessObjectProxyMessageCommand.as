package net.vdombox.ide.modules.wysiwyg.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxiesPipeMessage;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var sessionProxy : SessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
			
			var message : ProxiesPipeMessage = notification.getBody() as ProxiesPipeMessage;
			
			var body : Object = message.getBody();
			var place : String = message.getPlace();
			var target : String = message.getTarget();
			var operation : String = message.getOperation();
			
			switch ( target )
			{
				case PPMPageTargetNames.ATTRIBUTES:
				{
					if ( operation == PPMOperationNames.READ )
						sendNotification( ApplicationFacade.OBJECT_ATTRIBUTES_GETTED, body );
					else if ( operation == PPMOperationNames.UPDATE )
						var d : * = "";
					
					break;
				}
			}
		}
	}
}