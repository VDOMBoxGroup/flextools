package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;

	import mx.events.FlexEvent;

	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.SourceCode;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class SourceCodeMediatior extends Mediator implements IMediator
	{
		public static const NAME:String = "SourceCodeMediatior";
		private var objectTypeVO:ObjectTypeVO;

		public function SourceCodeMediatior( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showHandler );

		}


		private function validateObjectTypeVO(event: Event):void
		{
			view.label= "SourceCode*";
			objectTypeVO.sourceCode  = view.pythonScriptEditor.scriptAreaComponent.text;
		}

		private function showHandler(event:FlexEvent):void
		{
			view.removeEventListener(FlexEvent.SHOW, showHandler);
			compliteSourceCode();
		}


		protected function compliteSourceCode( ):void
		{	
			view.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			view.pythonScriptEditor.addEventListener( Event.CHANGE, validateObjectTypeVO );
			view.pythonScriptEditor.addedToStageHadler(null);
			view.pythonScriptEditor.loadSource( objectTypeVO.sourceCode, "zzz" );
		}		

		private function   keyDownHandler(event:KeyboardEvent):void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
//			view.setFocus();
			trace("setFok");
		}

		override public function listNotificationInterests():Array 
		{			
			return [ ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED:
					if (objectTypeVO == note.getBody() )
						view.label= "SourceCode";
					break;	
			}
		}

		protected function get view():SourceCode
		{
			return viewComponent as SourceCode;
		}
	}
}

