package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.events.FlexEvent;
	
	import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
	import net.vdombox.object_editor.model.vo.AttributeVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Languages;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class LanguagesMediator extends Mediator implements IMediator
	{
		public static const NAME:String 		= "LanguagesMediator";
		public static const ADD_LANGUAGE:String = "addLaguage";
		private var objectTypeVO:ObjectTypeVO;
		
		public function LanguagesMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showLanguages );
		//	view.addLaguage.addEventListener( MouseEvent.CLICK,   addLaguage );
		}
		
		private function showLanguages(event: FlexEvent): void
		{			
			view.languagesDataGrid.dataProvider = objectTypeVO.languages.words;
			view.validateNow();
		}
		
		private function addLaguage(event: FlexEvent): void
		{			
			view.languagesDataGrid.dataProvider = objectTypeVO.languages.words;
			view.validateNow();
		}
		
		protected function get view():Languages
		{
			return viewComponent as Languages;
		}
	}
}