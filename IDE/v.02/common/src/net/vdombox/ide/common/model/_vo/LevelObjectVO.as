package net.vdombox.ide.common.model._vo
{

	/**
	 * The LevelObjectVO is Visual Object of VDOM Level.
	 * LevelObjectVO is contained in VDOM Structure (StructureObjectVO).
	 */
	public class LevelObjectVO
	{
		public function LevelObjectVO( id : String )
		{
			_id = id;
		}

		public var level : uint;

		public var index : uint;

		private var _id : String;

		public function get id() : String
		{
			return _id;
		}

		public function toXML() : XML
		{
			return <Object ID={_id} Index={index}/>
		}
	}
}
