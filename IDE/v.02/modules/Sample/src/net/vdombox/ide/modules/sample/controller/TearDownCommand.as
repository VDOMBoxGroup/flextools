//Данная команда вызывается при остановке модуля, производит удаление и остановку отдельных компонентов.
package net.vdombox.ide.modules.sample.controller
{
	import net.vdombox.ide.modules.sample.view.BodyMediator;
	import net.vdombox.ide.modules.sample.view.SampleJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class TearDownCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var sampleJunctionMediator:SampleJunctionMediator =
				facade.retrieveMediator( SampleJunctionMediator.NAME ) as SampleJunctionMediator;
			
			sampleJunctionMediator.tearDown();
			
			facade.removeMediator( BodyMediator.NAME );
			
			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}