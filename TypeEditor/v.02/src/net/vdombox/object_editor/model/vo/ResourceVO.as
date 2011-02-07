// ActionScript file

package net.vdombox.object_editor.model.vo
{
	public class ResourceVO
	{
		public var id		:String = "";
		public var name		:String = "";
		public var type		:String = "";
		public var path		:String = "";	

		public function ResourceVO(id:String = "", name:String = "" , type:String = "" )
		{
			//Information
			this.id = id;
			this.name = name;
			this.type = type;
		}
	}
}

