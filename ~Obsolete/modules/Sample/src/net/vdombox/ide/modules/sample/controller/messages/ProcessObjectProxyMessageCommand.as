package net.vdombox.ide.modules.sample.controller.messages
{
	import net.vdombox.ide.common.PPMObjectTargetNames;
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.ObjectVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessObjectProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;
			
			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;
			
			var objectVO : ObjectVO;
			
			if ( body is ObjectVO )
				objectVO = body as ObjectVO;
			else if ( body.hasOwnProperty( "objectVO" ) )
				objectVO = body.objectVO as ObjectVO;
			else
				throw new Error( "no object VO" );
			
			switch ( target )
			{
				case PPMObjectTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.CREATE )
					{
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
					}

					break;
				}

				case PPMObjectTargetNames.ATTRIBUTES:
				{
					if ( operation == PPMOperationNames.READ )
					{
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
					}

					break;
				}
					
				case PPMObjectTargetNames.WYSIWYG:
				{
					if ( operation == PPMOperationNames.READ )
					{
					}
					
					break;
				}
					
				case PPMObjectTargetNames.XML_PRESENTATION:
				{
					if ( operation == PPMOperationNames.READ )
					{
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
					}
					
					break;
				}
			}
		}
	}
}