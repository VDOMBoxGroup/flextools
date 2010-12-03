package net.vdombox.object_editor.model
{
	public class ObjectShowing
	{
		private var _objectName:String;
//TODO: не знаю какого типа		
//		var private _objectPictures:Object;
		
		public function ObjectShowing( objectName: String)
		{			
			this._objectName = objectName;
		}
		
		public function get objectName(): String
		{
			return this._objectName;
		}
	}
}