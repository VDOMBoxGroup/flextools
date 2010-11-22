/*Данная команда используется для создания пали инструметов (Toolset) и ее посредника (ToolsetMediator), если
они не были созданы ранее, после чего посылается уведомление ApplicationFacade.EXPORT_TOOLSET*/
package net.vdombox.ide.modules.sample.controller
{
	import net.vdombox.ide.modules.sample.ApplicationFacade;
	import net.vdombox.ide.modules.sample.view.ToolsetMediator;
	import net.vdombox.ide.modules.sample.view.components.main.Toolset;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class CreateToolsetCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var toolset : Toolset;
			var toolsetMediator : ToolsetMediator;
			
			if( facade.hasMediator( ToolsetMediator.NAME ) )
			{
				toolsetMediator = facade.retrieveMediator( ToolsetMediator.NAME ) as ToolsetMediator;
				toolset = toolsetMediator.toolset;
			}
			else
			{
				toolset = new Toolset();
				facade.registerMediator( new ToolsetMediator( toolset ) )
			}
			
			facade.sendNotification( ApplicationFacade.EXPORT_TOOLSET, toolset );
		}
	}
}