package net.vdombox.ide.modules.sample.controller.messages
{
	import net.vdombox.ide.common.PPMOperationNames;
	import net.vdombox.ide.common.PPMPageTargetNames;
	import net.vdombox.ide.common.ProxyMessage;
	import net.vdombox.ide.common.vo.PageVO;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class ProcessPageProxyMessageCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var message : ProxyMessage = notification.getBody() as ProxyMessage;

			var body : Object = message.getBody();
			var target : String = message.target;
			var operation : String = message.operation;

			var pageVO : PageVO;
			
			if ( body is PageVO )
				pageVO = body as PageVO;
			else if ( body.hasOwnProperty( "pageVO" ) )
				pageVO = body.pageVO as PageVO;
			else
				throw new Error( "no page VO" );
			
			switch ( target )
			{
				case PPMPageTargetNames.OBJECT:
				{
					if ( operation == PPMOperationNames.CREATE )
					{
					}
					else if ( operation == PPMOperationNames.READ )
					{
					}
					else if ( operation == PPMOperationNames.DELETE )
					{
					}

					break;
				}

				case PPMPageTargetNames.WYSIWYG:
				{
					if ( operation == PPMOperationNames.READ )
					{
					}

					break;
				}

				case PPMPageTargetNames.XML_PRESENTATION:
				{
					if ( operation == PPMOperationNames.READ )
					{
					}
					else if ( operation == PPMOperationNames.UPDATE )
					{
					}

					break;
				}

				case PPMPageTargetNames.STRUCTURE:
				{
					if ( operation == PPMOperationNames.READ )
					{
					}

					break;
				}

				case PPMPageTargetNames.ATTRIBUTES:
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