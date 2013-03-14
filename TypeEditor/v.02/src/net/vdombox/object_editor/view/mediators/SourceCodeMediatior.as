/*
	Class SourceCodeMediatior is a wrapper over the SourceCode.mxml.
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.editors.PythonScriptEditor;
	import net.vdombox.object_editor.event.ScriptAreaComponenrEvent;
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

		private function validateObjectTypeVO(event: ScriptAreaComponenrEvent):void
		{
			addStar();
			objectTypeVO.sourceCode  = view.pythonScriptEditor.scriptAreaComponent.text;
		}

		private function showHandler(event:FlexEvent):void
		{
			view.removeEventListener(FlexEvent.SHOW, showHandler);
			compliteSourceCode();
		}

		protected function compliteSourceCode( ):void
		{	
			var pythonScriptEditor: PythonScriptEditor = view.pythonScriptEditor;
			pythonScriptEditor.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
			pythonScriptEditor.addEventListener( ScriptAreaComponenrEvent.TEXT_CHANGE, validateObjectTypeVO );
			pythonScriptEditor.addedToStageHadler(null);
			pythonScriptEditor.loadSource( objectTypeVO.sourceCode, "zzz" );
		}		

		private function   keyDownHandler(event:KeyboardEvent):void
		{
			event.stopPropagation();
			event.stopImmediatePropagation();
//			view.setFocus();
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
		
		protected function addStar():void
		{
			view.label= "SourceCode*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
		}
		
		protected function get view():SourceCode
		{
			return viewComponent as SourceCode;
		}
	}
}

