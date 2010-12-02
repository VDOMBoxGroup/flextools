package net.vdombox.object_editor.model.Proxy
{	
	public class MainProxy extends Proxy implements IProxy, IResponder
	{
		public static const NAME:String = "MainProxy";
		
		public function MainProxy ( data:Object = null ) 
		{
			super ( NAME, data );
		}
	}
}