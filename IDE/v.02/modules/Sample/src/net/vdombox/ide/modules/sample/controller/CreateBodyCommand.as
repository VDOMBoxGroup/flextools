/*Данная команда используется для создания основной части модуля (Body) и ее посредника (BodyMediator), если
они не были созданы ранее, после чего посылается уведомление ApplicationFacade.EXPORT_BODY*/
package net.vdombox.ide.modules.sample.controller
{
	import net.vdombox.ide.modules.sample.ApplicationFacade;
	import net.vdombox.ide.modules.sample.view.BodyMediator;
	import net.vdombox.ide.modules.sample.view.SampleMediator;
	import net.vdombox.ide.modules.sample.view.components.main.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class CreateBodyCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body;
			var bodyMediator : BodyMediator;
			
			var sampleMediator : SampleMediator = facade.retrieveMediator( SampleMediator.NAME ) as SampleMediator;
			
			if( facade.hasMediator( BodyMediator.NAME ) )
			{
				bodyMediator = facade.retrieveMediator( BodyMediator.NAME ) as BodyMediator;
				body = bodyMediator.body;
			}
			else
			{
				body = new Body();
				facade.registerMediator( new BodyMediator( body ) )
			}
			
//			данный хак используестя для того, чтобы в основной части(Body) испольлзовались стили
//			из этого модуля, иначе будут исполльзоваться стили ядра IDE Core
			body.moduleFactory = sampleMediator.sample.moduleFactory;
			
			facade.sendNotification( ApplicationFacade.EXPORT_BODY, body );
		}
	}
}